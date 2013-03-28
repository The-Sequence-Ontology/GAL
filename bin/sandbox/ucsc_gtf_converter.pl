use strict;
use warnings;

#-------------------------MAIN--------------------------------------------
#-------------------------------------------------------------------------

my $file = shift @ARGV;

my $features = parse_gtf($file);
my ($graph) = build_graph($features);
my $genes = build_genes($features, $graph);

print "## GFF3\n";
foreach my $g_id (keys %{$genes}) {
    my $gene = $genes->{$g_id};
    print_feature($gene);
    foreach my $t_id (keys %{$gene->{transcripts}}) {
	my $transcript = $gene->{transcripts}{$t_id};
	print_feature($transcript);
	foreach my $type (keys %{$transcript->{features}}) {
	    foreach my $feature (@{$transcript->{features}{$type}}) {
		print_feature($feature);
	    }
	}
    }
}
#-----------------------SUBS-----------------------------------------
#--------------------------------------------------------------------
sub parse_gtf {

    my $file = shift;

    open ( my $FH, '<', $file) or die "Could not open file: $file";

    my %features;
    while (my $line = <$FH>) {

	next if $line =~ /^\s*\#/;

	#Store the columns in temporary values that are delimited
	my ($seq_id, $source, $type, $start, $stop, $score, $strand,
	    $phase, $attributes) = split  /\t/, $line;

	my $t_id;

	#Capture the single $t_id for this line.
	if ($attributes  =~ /transcript_id\s+\"(.*?)\"/) {
	    $t_id = $1;
	}
	else {
	    die "No transcript ID in:\n$line\n";
	}

       #Collect all the information of the file and store that in a hash.
       #The purpose of doing so  is to retrieve it
       #later for association in gene modeling.
       my $feature = {seq_id => $seq_id,
		      source => $source,
		      type   => $type,
		      start  => $start,
		      stop   => $stop,
		      score  => $score,
		      strand => $strand,
		      phase  => $phase,
		      t_id   => $t_id,
		  };

	#Append anonymous hash to the %features hash.
	push @{$features{$t_id}{$type}}, $feature;

    }
    return \%features;
}
#-----------------------------------------------------------------------------
sub build_graph {

    my $features = shift;

    my %graph;
    # my %singletons;
   
    #First, find  transcript ids.
    for my $t1_id (keys %{$features}) {
	#Second, exclude all transcript ids that are not of type exon.
	#This transcript id represents the first comparator.
	for my $exon_1 (@{$features->{$t1_id}{exon} }) {
	    #Third, this transcript id represents the second comparator.
	    for my $t2_id (keys %{$features}) {
		#next if $t1_id eq $t2_id;
	      EXON2:
		for my $exon_2 (@{$features->{$t2_id}{exon}}) {

		    # Make sure we're on the same seq_id and strand
		    next if ($exon_1->{seq_id} ne $exon_2->{seq_id} ||
			     $exon_1->{strand} ne $exon_2->{strand}
			     );
		    
		    #If true overlap, create a bidirectional edge bewtween 
		    #exon_1 and exon_2.
		    if (overlaps($exon_1, $exon_2)) {
			$graph{$exon_1->{t_id}}{$exon_2->{t_id}}++;
			$graph{$exon_2->{t_id}}{$exon_1->{t_id}}++;
			
			#Don't dupicate the edges once they have been created.
			last EXON2;
		    }

# OLD CODE FROM SINGLETON DESIGN.

                       # delete $singletons{$exon_1->{t_id}}
		       # if exists $singletons{$exon_1->{t_id}};
		       #delete $singletons{$exon_2->{t_id}}
		       #if exists $singletons{$exon_2->{t_id}};

		       #else {
		             #$singletons{$exon_1->{t_id}}++;
		             #$singletons{$exon_2->{t_id}}++;
		       #}
		}
	    }
	}
    }
    return \%graph;
    # \%singletons;
}
#------------------------------------------------------------------------------
sub overlaps {
    
    my ($exon_1, $exon_2) = @_;

    if ($exon_1->{start} >= $exon_2->{start} &&
	$exon_1->{start} <= $exon_2->{stop})     {
	return 1;
    }
    elsif ($exon_1->{stop} >= $exon_2->{start} &&
	   $exon_1->{stop} <= $exon_2->{stop})     {
	return 1;
    }
    elsif ($exon_2->{start} >= $exon_1->{start} &&
	   $exon_2->{start} <= $exon_1->{stop})     {
	return 1;
    }
    elsif ($exon_2->{stop} >= $exon_1->{start} &&
	   $exon_2->{stop} <= $exon_1->{stop})     {
	return 1;
    }
    return undef;
}
#------------------------------------------------------------------------------
sub build_genes {

    my ($features, $graph) = @_;

    my $gene_clusters = get_clusters($graph);

    my %genes;
    my $counter;
    my $g_id_base = 'GENE_';
    my $g_id;
    my %feature_count;
    
    #Note: if the design requires singleton hash once more, remember to 
    #assign it a unique g_id. 
   
    for my $t_ids (@{$gene_clusters}) {
        $g_id = $g_id_base . $counter++;
	my ($seq_id, $source, $g_min, $g_max, $strand);
	$g_min = 10_000_001;
	$g_max = -2;
	my %transcripts;

	for my $t_id (@{$t_ids}) {
	    my ($t_min, $t_max) = (10_000_000, -1);
	    for my $type (keys %{$features->{$t_id}}) {
		my @features;
		if ($features->{$t_id}{$type}[0]{strand} eq '+') {
		    @features = sort {$a->{start} <=> $b->{stop}}
		    @{$features->{$t_id}{$type}};
		}
		else {
		    @features = sort {$b->{start} <=> $a->{stop}}
		    @{$features->{$t_id}{$type}};
		}
		for my $feature (@features) {
		    
		    
		    $feature->{parent} = $t_id;
		    my $id = "$t_id:$type:". ++$feature_count{$t_id}{$type};
		    $feature->{id} = $id;
		    
		    $seq_id ||= $feature->{seq_id};
		    $source ||= $feature->{source};
		    $strand ||= $feature->{strand};
		    
		    $t_min = $feature->{start} < $t_min ?
			$feature->{start} : $t_min;
		    $t_max = $feature->{stop} > $t_max ?
			$feature->{stop} : $t_max;
		}
	    }
	    $transcripts{$t_id} = {seq_id   => $seq_id,
				   source   => $source,
				   type     => 'mRNA',
				   start    => $t_min,
				   stop     => $t_max,
				   score       => '.',
				   strand   => $strand,
				   phase       => '.', 
				   features => $features->{$t_id},
				   parent   => $g_id,
				   id       => $t_id,
			       };
	    
	    $g_min = $t_min < $g_min ?
		$t_min : $g_min;
	    $g_max = $t_max > $g_max ?
		$t_max : $g_max;
	}
	$genes{$g_id} = {seq_id      => $seq_id,
			 source      => $source,
			 type        => 'gene',
			 start       => $g_min,
			 stop        => $g_max,
			 score       => '.', 
			 strand      => $strand,
			 phase       => '.',  
			 transcripts => \%transcripts,
			 id          => $g_id,
			     
			     
			     
			     
		     };   
	    
    }
    return \%genes;
}
#-----------------------------------------------------------------------------
sub get_clusters {

    my $graph = shift;

    my @clusters;
    my $visited = {};
    for my $i (keys %{$graph}) {

	next if $visited->{$i};
	$visited->{$i}++;

	my $subgraph = {};
	$subgraph->{$i}++;
	$subgraph = collect_vertices($graph, $i, $visited, $subgraph);
	push @clusters,  [keys %{$subgraph}];

    }
    return \@clusters;
}
#-----------------------------------------------------------------------------
sub collect_vertices {

    my ($graph, $i, $visited, $subgraph) = @_;

    for my $j (keys %{$graph->{$i}}) {
	next if $visited->{$j};
	$visited->{$j}++;
	$subgraph->{$j}++;
	
        #my $subgraph = collect_vertices($graph, $j, $visited, $subgraph);

 	collect_vertices($graph, $j, $visited, $subgraph);
    }

    return $subgraph;
}
#-----------------------------------------------------------------------------
sub print_feature {

    my $feature = shift;

    print join "\t", ($feature->{seq_id},
		      $feature->{source},
		      $feature->{type},
		      $feature->{start},
		      $feature->{stop},
		      $feature->{score},
		      $feature->{strand},
		      $feature->{phase},
		      );
    print "\tID=" . $feature->{id} . ';';
    if ($feature->{parent}) {
	print "Parent=" . $feature->{parent} . ';';
    }
    print "\n";
    
}

__END__

    foreach my $vertex (keys %{$graph) {

	if ($vertex->{edges} > 1) {
	    build_genes ($graph);
	    $vertex->{edges}--;
	}
	else  {

	}


}
