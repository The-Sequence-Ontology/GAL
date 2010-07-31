../gff_tool --blend data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --filter '$f->{seqid} == 4' data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --alter '$f->{seqid} = "X"' data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --hash_ag 'push @{$hash_ag{$f->{type}}}, $f' --ag_code 'my @x = sort {($a->{end} - $a->{start}) <=> ($b->{end} - $b->{start})} @$value;shift @x' data/dmel-4-r5.27_no_fasta.gff
../gff_tool --grab_headers 10Gen_Chinese_SNV_partial.gvf
../gff_tool --out_ext .header --grab_headers 10Gen_Chinese_SNV_partial.gvf 
../gff_tool --add_headers 10Gen_Chinese_SNV_partial.gvf.header junk.gff 

