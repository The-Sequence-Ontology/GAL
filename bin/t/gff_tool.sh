../gff_tool --blend data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --filter '$f->{seqid} == 4' data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --alter '$f->{seqid} = "X"' data/dmel-4-r5.27_no_fasta.gff 
../gff_tool --hash_ag 'push @{$hash_ag{$f->{type}}}, $f' --ag_code 'my @x = sort {($a->{end} - $a->{start}) <=> ($b->{end} - $b->{start})} @$value;shift @x' data/dmel-4-r5.27_no_fasta.gff
../gff_tool --grab_headers 10Gen_Chinese_SNV_partial.gvf
../gff_tool --out_ext .header --grab_headers 10Gen_Chinese_SNV_partial.gvf 
../gff_tool --add_headers 10Gen_Chinese_SNV_partial.gvf.header junk.gff 

../gff_tool --filter
../gff_tool --merge_gff
../gff_tool --blend_gff
../gff_tool --sort_gff
../gff_tool --alter_gff
../gff_tool --hash_ag
../gff_tool --validate
../gff_tool --stats
../gff_tool --fasta_feature
../gff_tool --fasta_add
../gff_tool --fasta_only
../gff_tool --fasta_no
../gff_tool --add_ID
../gff_tool --pragmas
../gff_tool --headers_only
../gff_tool --headers_no
../gff_tool --meta_add
../gff_tool --features
../gff_tool --union
../gff_tool --intersection
../gff_tool --l_compliment
../gff_tool --s_difference
../gff_tool --calc_titv
../gff_tool --get_so_data
