../gff_tool --filter --code '$f->{seqid} == 4' data/dmel-4-r5.27_no_fasta.gff 
#../gff_tool --merge_gff
../gff_tool --blend data/dmel-4-r5.27_no_fasta.gff  data/dmel-4-chromosome-r5.29.fasta
#../gff_tool --sort_gff
../gff_tool --alter --code '$f->{seqid} = "X"' data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --hash_ag 'push @{$hash_ag{$f->{type}}}, $f' --code 'my @x = sort {($a->{end} - $a->{start}) <=> ($b->{end} - $b->{start})} @$value;shift @x' data/dmel-4-r5.27_no_fasta.gff

../gff_tool --validate data/dmel-4-r5.27_no_fasta.gff
../gff_tool --validate data/10Gen_Chinese_SNV_partial.gvf
#../gff_tool --stats
#../gff_tool --fasta_feature
#../gff_tool --fasta_add data/dmel
#../gff_tool --fasta_only
#../gff_tool --fasta_no
#../gff_tool --add_ID
#../gff_tool --pragmas
#../gff_tool --headers_only 10Gen_Chinese_SNV_partial.gvf
#../gff_tool --out_ext .header --headers_only 10Gen_Chinese_SNV_partial.gvf 
#../gff_tool --add_headers 10Gen_Chinese_SNV_partial.gvf.header junk.gff 
#../gff_tool --headers_no
#../gff_tool --meta_add
#../gff_tool --features
#../gff_tool --union
#../gff_tool --intersection
#../gff_tool --l_compliment
#../gff_tool --s_difference
#../gff_tool --calc_titv
#../gff_tool --get_so_data
