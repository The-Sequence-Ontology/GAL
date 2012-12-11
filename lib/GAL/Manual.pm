=pod 

=head1 INTRODUCTION:

=head2 Justification

=head1 MAJOR FEATURES:

=head1 LIBRARY STRUCTURE:

=head2 Schema/Object Structure

Based on GFF3 structure

Hash references vs. objects

GAL::Annotation - Genome Annotation Library
GAL::Base - Base class for the Genome Annotation Library
GAL::Parser - Parser objects for the Genome Annotation Library
GAL::Reader - Reader objects for the Genome Annotation Library
GAL::Storage - <One line description of module's purpose here>
GAL::Schema - DBIx::Class functionality for the Genome Annotation Library
GAL::List - List aggregation and analysis functions for GAL
GAL::Feature - <One line description of module's purpose here>
GAL::Index - <One line description of module's purpose here>
GAL::Parser::gff3 - Parse GFF3 files
GAL::Reader::DelimitedLine -  Delimited file parsing for GAL
GAL::Reader::RecordParser - Record Parsing using Text::RecordParser
GAL::Schema::Result::Feature - Base class for all sequence features
GAL::Schema::Result::Attribute - Access to feature attributes for GAL::Schema::Result::Features
GAL::Schema::Result::Relationship - Access to relationships for <GAL::Schema::Result::Feature> objects.
GAL::Schema::Result::Feature::gene -  A gene object for the GAL Library
GAL::Schema::Result::Feature::transcript - A transcript object for the GAL
GAL::Schema::Result::Feature::exon -  A exon object for the GAL Library
GAL::Schema::Result::Feature::cds - A CDS object for the GAL Library

=head2 Structure of the objects

=head1 BASIC USAGE:

=head1 SEQUENCE ONTOLOGY INTEGRATION:

=head1 PERFORMANCE:

=head1 FAQ:

=head1 COOKBOOK:

=head1 TROUBLESHOOTING:

=head1 GLOSSARY:

=head1 TODO:


GAL::Annotation - Genome Annotation Library

=head1 VERSION

This document describes GAL::Annotation version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;

    my $feat_store = GAL::Annotation->new(fasta => '/path/to/fasta_dir/');

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			   );

    my $features = $feat_store->schema->resultset('Feature');

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
      print $mrna->feature_id . "\n";
      my $CDSs = $mrna->CDSs;
      while (my $CDS = $CDSs->next) {
	print join "\n", ($CDS->start,
			  $CDS->end,
			  $CDS->seq,
			 );
      }
    }

=head1 DESCRIPTION

The Genome Annotation Library is a collection of modules that strive
to make working with genome annotations simple, intuitive and fast.
Users of GAL first create an annotation object which in turn will
contain Parser, Storage and Schema objects.  The parser allows
features to be loaded into GAL's storage from a variety of formats.
The storage object specifies how the features should be stored, and
the schema object provides flexible query and iteration functions over
the features.  In addtion, Index objects (not yet implimented) provide
additional key/value mapped look up tables, and List objects provide
aggregation and analysis functionality for lists of feature
attributes.

A wide variety of parsers are available to convert sequence features
from various formats, and new parsers are easy to write.  See
GAL::Parser for more details.  Currently MySQL and SQLite storage
options are available (a fast RAM storage engine is on the TODO list).
Schema objects are provided by DBIx::Class and a familiarity with that
package is necessary to understanding how to query and iterate over
feature objects.

=head1 CONSTRUCTOR

New Annotation objects are created by the class method new.  Arguments
should be passed to the constructor as a list (or reference) of key
value pairs.  All attributes of the Annotation object can be set in
the call to new, but reasonable defaults will be used where ever
possilbe to keep object creation simple.  An simple example of object
creation would look like this:

    my $feat_store = GAL::Annotation->new();

The resulting object would use a GFF3 parser and SQLite storage by
default and it would not have access to feature sequence.

A more complex object creation might look like this:

    my $feat_store = GAL::Annotation->new(parser  => {class => gff3},
					  storage => {class => mysql,
						      dsn   => 'dbi:mysql:database'
						      user  => 'me',
						      password => 'secret'
					  fasta   =>  '/path/to/fasta/files/'
					  );

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< parser => parser_subclass [gff3] >>

This optional parameter defines which parser subclass to instantiate.
This parameter will default to gff3 if not provided.  See GAL::Parser
for a complete list of available parser classes.

=item * C<< storage => storage_subclass [SQLite] >>

This optional parameter defines which storage subclass to instantiate.
Currently available storage classes are SQLite (the default) and
mysql.

=item * C<< fasta => '/path/to/fasta/files/ >>

This optional parameter defines a path to a collection of fasta files
that correspond the annotated features.  The IDs (first contiguous
non-whitespace charachters) of the fasta headers must correspond to
the sequence IDs (seqids) in the annotated features.  The fasta
parameter is optional, but if the fasta attribute is not set then the
features will not have access to their sequence.  Access to the
sequence in provided by Bio::DB::Fasta.

=cut
=head2 new

     Title   : new
     Usage   : GAL::Annotation->new();
     Function: Creates a GAL::Annotation object;
     Returns : A GAL::Annotation object
     Args    : A list of key value pairs for the attributes specified above.

=cut
=head1  ATTRIBUTES

All attributes can be supplied as parameters to the GAL::Annotation
constructor as a list (or referenece) of key value pairs.

=cut
=head2 parser

 Title   : parser
 Usage   : $parser = $self->parser();
 Function: Create or return a parser object.
 Returns : A GAL::Parser::subclass object.
 Args    : (class => gal_parser_subclass)
	   See GAL::Parser and it's subclasses for more arguments.
 Notes   : The parser object is created as a singleton, but it
	   can be changed by passing new arguments to a call to
	   parser.

=cut
=head2 storage

  Title   : storage
  Usage   : $storage = $self->storage();
  Function: Create or return a storage object.
  Returns : A GAL::Storage::subclass object.
  Args    : (class => gal_storage_subclass)
	    See GAL::Storage and it's subclasses for more arguments.
  Notes   : The storage object is created as a singleton and can not be
	    destroyed or recreated after being created.

=cut
=head2 fasta

The fasta attribute is provided by GAL::Base, see that module for more
details.

=cut
=head1 Methods


=head2 schema

  Title   : schema
  Usage   : $self->schema();
  Function: Create and/or return the DBIx::Class::Schema object
  Returns : DBIx::Class::Schema object.
  Args    : N/A - Arguments are provided by the GAL::Storage object.

=cut
=head2 load_files

 Title   : load_files
 Usage   : $a = $self->load_files();
 Function: Parse and store all of the features in a file.
 Returns : N/A
 Args    : (files => \@feature_files,
	    mode  => 'overwrite',
	   )
 Notes   : Default

=cut
=head1 DIAGNOSTICS

<GAL::Annotation> currently does not throw any warnings or errors, but
most other modules in the library do, and details of those errors can
be found in those modules.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Annotation> requires no configuration files or environment variables.

=head1 DEPENDENCIES

Modules in GAL/lib use the following modules:

Bio::DB::Fasta
Carp
DBD::SQLite
DBD::mysql
DBI
File::Temp
List::Util
Scalar::Util
Set::IntSpan::Fast
Statistics::Descriptive
Text::RecordParser

Some script in GAL/bin and/or GAL/lib/GAL/t use the following modules:

Data::Dumper
FileHandle
Getopt::Long
Getopt::Std
IO::Prompt
List::MoreUtils
TAP::Harness
Test::More
Test::Pod::Coverage
URI::Escape
XML::LibXML::Reader

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

I'm sure there are plenty of bugs right now - please let me know if you find one.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Base - Base class for the Genome Annotation Library

=head1 VERSION

This document describes GAL::Base version 0.2.0

=head1 SYNOPSIS

    use base qw(GAL::Base);

=head1 DESCRIPTION

GAL::Base serves as a base class for all of the other classes in the
GAL.  It is not intended to be instantiated directly, but rather to be
used with the 'use base' pragma.  GAL::Base provides object
instantiation, argument preparation and attribute setting functions
for other classes during object construction.  In addition it provides
a wide range of utility functions that are expected to be widly
applicable throughout the library.

=head1 METHODS

=cut
=head2 new

     Title   : new
     Usage   : GAL::Base->new();
     Function: Creates a GAL::Base object;
     Returns : A GAL::Base object
     Args    : fasta => '/path/to/fasta/files/'

=cut
=head2 fasta

  Title   : fasta
  Usage   : $fasta = $self->fasta($fasta_dir);
  Function: Provides a Bio::DB::Fasta object
  Returns : A Bio::DB::Fasta object
  Args    : A directory of fasta files.

=cut
=head2 throw

 Title   : throw
 Usage   : $base->throw($err_code, $err_msg);
 Function: Throw an error - print an error message and die.
 Returns : None
 Args    : message => $err_msg  # Free text description of error
           code    => $err_code # single_word_code_for_error

=cut
=head2 warn

 Title   : warn
 Usage   : $base->warn($code, $message);
 Function: Send a warning.
 Returns : None
 Args    : message => $warning_message

=cut
=head2 wrap_text

 Title   : wrap_text
 Usage   : $text = $self->wrap_text($text, 50);
 Function: Wrap text to the specified column width.
 Returns : Wrapped text
 Args    : A string of text and an optional integer value.

=cut
=head2 trim_whitespace

 Title   : trim_whitespace
 Usage   : $trimmed_text = $self->trim_whitespace($text);
 Function: Trim leading and trailing whitespace from text;
 Returns : Trimmed text.
 Args    : Text

=cut
=head2 prepare_args

 Title   : prepare_args
 Usage   : $args = $self->prepare_args(@_);
 Function: Take a list of key value pairs that may be an array, hash or ref
	   to either and return them as a hash or hash reference depending on
	   calling context.
 Returns : Hash or hash reference
 Args    : An array, hash or reference to either

=cut
=head2 set_attributes

 Title   : set_attributes
 Usage   : $base->set_attributes($args, @valid_attributes);
 Function: Take a hash reference of arguments and a list of valid attribute
	   names and call the methods to set those attribute values.
 Returns : None
 Args    : A hash reference of arguments and an array or array reference of
	   valid attributes names.

=cut
=head2 expand_iupac_nt_codes

 Title   : expand_iupac_nt_codes
 Usage   : @nucleotides = $self->expand_iupac_nt_codes('W');
 Function: Expands an IUPAC ambiguity codes to an array of nucleotides
 Returns : An array or array ref of nucleotides
 Args    : An IUPAC Nucleotide ambiguity code or an array of such

=cut
=head2 load_module

 Title   : load_module
 Usage   : $base->load_module(Some::Module);
 Function: Do runtime loading (require) of a module/class.
 Returns : 1 on success - throws exception on failure
 Args    : A valid module name

=cut
=head2 revcomp

 Title   : revcomp
 Usage   : $base->revcomp($feature);
 Function: Get the reverse compliment of a nucleotide sequence
 Returns : The reverse complimented sequence
 Args    : A nucleotide sequence

=cut
=head2 get_feature_bins

 Title   : get_feature_bins
 Usage   : $base->get_feature_bins($feature);
 Function: Get the genome bins for a range
 Returns : An array of bins that the given
	   range falls in.
 Args    : A hash reference with key values seqid, start, end (i.e. a
	   feature hash)

=cut
=head2 translate

 Title   : translate
 Usage   : $base->translate($sequence, $offset, $length);
 Function: Translate a nucleotide sequence to an amino acid sequence
 Returns : An amino acid sequence
 Args    : The sequence as a scalar, and integer offset and an integer
	   length

=cut
=head2 genetic_code

 Title   : genetic_code
 Usage   : $base->genetic_code;
 Function: Returns a hash reference of the genetic code
 Returns : A hash reference of the genetic code
 Args    : None

=cut
=head2 time_stamp

 Title   : time_stamp
 Usage   : $base->time_stamp;
 Function: Returns a YYYYMMDD time_stamp
 Returns : A YYYYMMDD time_stamp
 Args    : None

=cut
=head2 random_string

 Title   : random_string
 Usage   : $base->random_string;
 Function: Returns a random alphanumeric string
 Returns : A random alphanumeric string
 Args    : The length of the string to be returned [8]

=cut
=head2 float_lt

 Title   : float_lt
 Usage   : $base->float_lt(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is less than (<) the
	   second number at a given level of accuracy.
 Returns : 1 if the first number is less than the second, otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut
=head2 float_le

 Title   : float_le
 Usage   : $base->float_le(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is less than or equal to
	   (<=) the second number at a given level of accuracy.
 Returns : 1 if the first number is less than or equal to the second,
	   otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut
=head2 float_gt

 Title   : float_gt
 Usage   : $base->float_gt(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is greater than (>) the
	   second number at a given level of accuracy.
 Returns : 1 if the first number is greater than the second, otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut
=head2 float_ge

 Title   : float_ge
 Usage   : $base->float_ge(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is greater than or equal
           to (>=) the second number at a given level of accuracy.
 Returns : 1 if the first number is greater than or equal to the second,
           otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut
=head1 DIAGNOSTICS

=over

=item C<< invalid_arguments_to_prepare_args >>

<GAL::Base::prepare_args> accepts an array, a hash or a reference to either
an array or hash, but it was passed something different.

=item C<< invalid_ipuac_nucleotide_code >>

<GAL::Base::expand_iupac_nt_codes> was passed a charachter that is not a valid
IUPAC nucleotide code (http://en.wikipedia.org/wiki/Nucleic_acid_notation).

=item C<< failed_to_load_module >>

<GAL::Base::load_module> was unable to load (require) the specified module.
The module may not be installed or it may have a compile time error.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Base> requires no configuration files or environment variables.

=head1 DEPENDENCIES

=over

=item C<< Carp qw(croak cluck) >>

=item C<< Bio::DB::Fasta >>

=back

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Parser - Parser objects for the Genome Annotation Library

=head1 VERSION

This document describes GAL::Parser version 0.2.0

=head1 SYNOPSIS

    use GAL::Parser;

    my $parser = GAL::Parser::gff3->new(file => 'data/feature.gff3');

    while (my $feature_hash = $parser->next_feature_hash) {
	print $parser->to_gff3($feature_hash) . "\n";
    }


=head1 DESCRIPTION

<GAL::Parser> is not intended to be instantiated by itself, but rather
functions as a base class for <GAL::Parser> subclasses.  It provides a
variety of attributes and methods that are generally applicable to all
parsers.  While parsers are intended for use from within
<GAL::Annotation> objects. Parsers can be instantiated seperately from
the rest of the GAL library and there are many use cases for the
parsers as stand alone objects.  Anytime you just need fast access to
iterate over all features in a flat file and are happy to have hashes
of those features you should just use the parser directly without the
<GAL::Annotation> object.

=head1 CONSTRUCTOR

New GAL::Parser::subclass objects are created by the class method
new.  Arguments should be passed to the constructor as a list (or
reference) of key value pairs.  All attributes of the Parser object
can be set in the call to new. An simple example
of object creation would look like this:

    my $parser = GAL::Parser::gff3->new(file => 'data/feature.gff3');

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< file => feature_file.txt >>

This optional parameter provides the filename for the file containing
the data to be parsed. While this parameter is optional either it, or
the following fh parameter must be set.

=item * C<< fh => feature_file.txt >>

This optional parameter provides a filehandle to read data from. While
this parameter is optional either it, or the following fh parameter
must be set.

=item * C<< annotation => $gal_annotation_object >>

This parameter is not intended for public use as a setter, but it is
available for use as a getter.  When a parser is instantiated via
<GAL::Annotation>, a weakened copy of the <GAL::Annotation> object is
stored in the parser.

=back

=cut
=head2 new

     Title   : new
     Usage   : GAL::Parser::subclass->new();
     Function: Creates a GAL::Parser object;
     Returns : A GAL::Parser object
     Args    : (file => $file)
	       (fh   => $FH)

=cut
=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor as a
list (or referenece) of key value pairs.

=head2 annotation

 Title   : annotation
 Usage   : $a = $self->annotation()
 Function: Get/Set the value of annotation.
 Returns : The value of annotation.
 Args    : A value to set annotation to.

=cut
=head2 file

 Title   : file
 Usage   : $a = $self->file();
 Function: Get/Set the value of file.
 Returns : The value of file.
 Args    : A value to set file to.

=cut
=head2 fh

 Title   : fh
 Usage   : $a = $self->fh();
 Function: Get/Set the filehandle.
 Returns : The filehandle.
 Args    : A filehandle.

=cut
=head2 reader

 Title   : reader
 Usage   : $a = $self->reader();
 Function: Get/Set the reader.
 Returns : The value of reader.
 Args    : A value to set reader to.

=cut
=head1 METHODS

=head2 next_record

 Title   : next_record
 Usage   : $a = $self->next_record();
 Function: Return the next record from the reader in whatever format
	   that reader specifies.
 Returns : The next record from the reader.
 Args    : N/A

=cut
=head2 next_feature_hash

 Title   : next_feature_hash
 Usage   : $a = $self->next_feature_hash;
 Function: Return the next record from the parser as a 'feature hash'.
 Returns : A hash or hash reference.
 Args    : N/A

The feature hash has the following format:

%feature = (feature_id => $feature_id,
	    seqid      => $seqid,
	    source     => $source,
	    type       => $type,
	    start      => $start,
	    end        => $end,
	    score      => $score,
	    strand     => $strand,
	    phase      => $phase,
	    attributes => {ID => $feature_id,
			   Parent => $parent_id,
			  }
	   );

This hash follows the format layed out by the GFF3 specification
(http://www.sequenceontology.org/resources/gff3.html).  Please see
that document for details on constrants for each value and attribute.

=cut
=head2  to_gff3

 Title   : to_gff3
 Usage   : $self->to_gff3($feature_hash)
 Function: Returns a string of GFF3 formatted text for a given feature hash
 Returns : A string in GFF3 format.
 Args    : A feature hash reference in the form returned by next_feature_hash

=cut
=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : Feature data as a hash (or reference);
 Args    : A data structure of feature data that this method (probably
	   overridden by a subclass) understands.

=cut
=head2 parse_attributes

 Title   : parse_attributes
 Usage   : $a = $self->parse_attributes($attrb_text);
 Function: Parse the attributes from a GFF3 column 9 formatted string of text.
 Returns : A hash (or reference) of attribute key value pairs.
 Args    : A GFF3 column 9 formated string of text.

=cut
=head1 DIAGNOSTICS

<GAL::Parser> currently does not throw any warnings or errors, but
subclasses may, and details of those errors can be found in those
modules.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Parser> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Reader>

<GAL::Reader> and subclasses of <GAL::Parser> have other dependencies.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Reader - Reader objects for the Genome Annotation Library

=head1 VERSION

This document describes GAL::Reader version 0.2.0

=head1 SYNOPSIS

  use GAL::Reader::DelimitedLine;
  $reader = GAL::Reader::DelimitedLine->new(field_names => \@field_names);

=head1 DESCRIPTION

<GAL::Reader>, via it's subclasses, provides file reading access for a
variety of file formats.  The reader objects don't parse the
information in the files themselves, but rather provide standard
access to broad categories of formats such as tab-delimited,
multi-line record, XML files and others.  <GAL::Reader> should not be
instantiated on it's own, but rather acts as a base class for
functionality common to all readers.

=head1 CONSTRUCTOR

New GAL::Reader::subclass objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  All attributes of the Reader object can be set in
the call to new. An simple example of object creation would look like
this:

  $reader = GAL::Reader::DelimitedLine->new(field_names => \@field_names);

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< file => feature_file.txt >>

This optional parameter defines what file to parse. While this
parameter is optional either it, or the following fh parameter must be
set before the first call to next_record.

=item * C<< fh => $FH >>

This optional parameter provides a file handle to parse. While this
parameter is optional, either it or the previous must be set before
the first call to next_record.

=back

Other attributes are used by subclasses of <GAL::Reader>.  See those modules
for details.

=cut
=head2 new

     Title   : new
     Usage   : GAL::Reader::DelimitedLine->new();
     Function: Creates a GAL::Reader::DelimitedLine object;
     Returns : A GAL::Reader::DelimitedLine object
     Args    : See <GAL::Reader::DelimitedLine> and other subclasses.

=cut
=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor as a
list (or referenece) of key value pairs.

=head2 file

 Title   : file
 Usage   : $a = $self->file();
 Function: Get/Set the value of file.
 Returns : The value of file.
 Args    : The filename of a readable file.

=cut
=head2 fh

 Title   : fh
 Usage   : $a = $self->fh();
 Function: Get/Set the filehandle.  Once the file handle is set, the same
	   file handle is returned until another file handle is passed in.
 Returns : A filehandle
 Args    : A filehandle

=cut
=head1 METHODS

=head2 _external_reader

 Title   : _external_reader
 Usage   : $a = $self->_external_reader();
 Function: Get/Set the _external_reader if one is used.  This allows, for
	   example, Text::RecordParser or XML::Twig to be easily added as
	   an external reader by subclasses.
 Returns : The value of _external_reader.
 Args    : A value to set _external_reader to.

=cut
=head2 next_record

 Title   : next_record
 Usage   : $a = $self->next_record();
 Function: Return the next record from the external_reader.  Note that this
	   method must be overridden by a sublass of GAL::Reader.
 Returns : The next record from the external_reader.
 Args    : N/A

=cut
=head1 DIAGNOSTICS

=over

=item C<< file_doesnt_exist >>

GAL::Reader tried to open a file that did not exist.  Please check you
file path and filename.

=item C<< cant_read_file >>

GAL::Reader tried to open a file that exists, but could not be read.
Please check your file permissions.

=item C<< failed_to_open_file >>

GAL::Reader tried to open a file, but failed.

=item C<< method_must_be_overridden >>

GAL::Parser::next_record must be overridden by a subclasses of
<GAL::Parser>, but this was not done.  Please contact the author of
the subclass that you were using.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Reader> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Base>

Subclasses of GAL::Reader may have additional dependencies.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Storage - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Storage version 0.2.0

=head1 SYNOPSIS

     use GAL::Storage;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut
=head2 new

     Title   : new
     Usage   : GAL::Storage->new()
     Function: Creates a Storage object;
     Returns : A Storage object
     Args    :

=cut
=head2 annotation

 Title   : annotation
 Usage   : $a = $self->annotation()
 Function: Get/Set the value of annotation.
 Returns : The value of annotation.
 Args    : A value to set annotation to.

=cut
=head2 dsn

 Title   : dsn
 Usage   : $a = $self->dsn()
 Function: Get/Set the value of dsn.
 Returns : The value of dsn.
 Args    : A value to set dsn to.

=cut
=head2 scheme

 Title   : scheme
 Usage   : $a = $self->scheme()
 Function: Get/Set the value of scheme.
 Returns : The value of scheme.
 Args    : A value to set scheme to.

=cut
=head2 user

 Title   : user
 Usage   : $a = $self->user()
 Function: Get/Set the value of user.
 Returns : The value of user.
 Args    : A value to set user to.

=cut
=head2 password

 Title   : password
 Usage   : $a = $self->password()
 Function: Get/Set the value of password.
 Returns : The value of password.
 Args    : A value to set password to.

=cut
=head2 database

 Title   : database
 Usage   : $a = $self->database();
 Function: Get/Set the value of database.
 Returns : The value of database.
 Args    : A value to set database to.

=cut
=head2 driver

 Title   : driver
 Usage   : $a = $self->driver()
 Function: Get/Set the value of driver.
 Returns : The value of driver.
 Args    : A value to set driver to.

=cut
=head2 _load_schema

 Title   : _load_schema
 Usage   : $self->_load_schema();
 Function: Get/Set value of _load_schema.
 Returns : Value of _load_schema.
 Args    : Value to set _load_schema to.

=cut
=head2 load_files

 Title   : load_files
 Usage   : $self->load_files();
 Function: Get/Set value of load_file.
 Returns : Value of load_file.
 Args    : Value to set load_file to.

=cut
=head2 add_features_to_buffer

 Title   : add_features_to_buffer
 Usage   : $self->add_features_to_buffer()
 Function: Get/Set value of add_features_to_buffer.
 Returns : Value of add_features_to_buffer.
 Args    : Value to set add_feature to.

=cut
=head2 flush_buffer

 Title   : flush_buffer
 Usage   : $self->flush_buffer()
 Function: Get/Set value of flush_buffer.
 Returns : Value of flush_buffer.
 Args    : Value to set add_feature to.

=cut
=head2 prepare_features

 Title   : prepare_features
 Usage   : $self->prepare_features()
 Function: Normalizes feature hashes produced by the parsers
	   and seperates the attributes for bulk insert into the database;
 Returns : A feature hash reference and an array reference of hash references
	   of attributes.  Both normalized for insert statements
 Args    : A feature hash or array of feature hashes

=cut
=head2 add_features

 Title   : add_features
 Usage   : $self->add_features()
 Function: Get/Set value of add_feature.
 Returns : Value of add_feature.
 Args    : Value to set add_feature to.

=cut
=head2 create_database

 Title   : create_database
 Usage   : $self->create_database()
 Function: Create the database if it doesnt exists.
 Returns : Success
 Args    : N/A

=cut
=head2 get_children

 Title   : get_children
 Usage   : $self->get_children()
 Function: Get/Set value of get_children.
 Returns : Value of get_children.
 Args    : Value to set get_children to.

=cut
=head2 get_children_recursively

 Title   : get_children_recursively
 Usage   : $self->get_children_recursively()
 Function: Get/Set value of get_children_recursively.
 Returns : Value of get_children_recursively.
 Args    : Value to set get_children_recursively to.

=cut
=head2 get_parents

 Title   : get_parents
 Usage   : $self->get_parents()
 Function: Get/Set value of get_parents.
 Returns : Value of get_parents.
 Args    : Value to set get_parents to.

=cut
=head2 get_parents_recursively

 Title   : get_parents_recursively
 Usage   : $self->get_parents_recursively()
 Function: Get/Set value of get_parents_recursively.
 Returns : Value of get_parents_recursively.
 Args    : Value to set get_parents_recursively to.

=cut
=head2 get_all_features

 Title   : get_all_features
 Usage   : $self->get_all_features()
 Function: Get/Set value of get_all_features.
 Returns : Value of get_all_features.
 Args    : Value to set get_all_features to.

=cut
=head2 get_features_by_type

 Title   : get_features_by_type
 Usage   : $self->get_features_by_type()
 Function: Get/Set value of get_features_by_type.
 Returns : Value of get_features_by_type.
 Args    : Value to set get_features_by_type to.

=cut
=head2 get_recursive_features_by_type

 Title   : get_recursive_features_by_type
 Usage   : $self->get_recursive_features_by_type()
 Function: Get/Set value of get_recursive_features_by_type.
 Returns : Value of get_recursive_features_by_type.
 Args    : Value to set get_recursive_features_by_type to.

=cut
=head2 get_feature_by_id

 Title   : get_feature_by_id
 Usage   : $self->get_feature_by_id()
 Function: Get/Set value of get_feature_by_id.
 Returns : Value of get_feature_by_id.
 Args    : Value to set get_feature_by_id to.

=cut
=head2 filter_features

 Title   : filter_features
 Usage   : $self->filter_features()
 Function: Get/Set value of filter_features.
 Returns : Value of filter_features.
 Args    : Value to set filter_features to.

=cut
=head2 foo

 Title   : foo
 Usage   : $a = $self->foo()
 Function: Get/Set the value of foo.
 Returns : The value of foo.
 Args    : A value to set foo to.

=cut
=head1 DIAGNOSTICS

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Storage> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema - DBIx::Class functionality for the Genome Annotation Library

=head1 VERSION

This document describes GAL::Schema version 0.2.0

=head1 SYNOPSIS

    use GAL::Schema;
    my $schema = GAL::Schema->connect($dsn,
                                      $user,
                                      $password,
                                     );

=head1 DESCRIPTION

<GAL::Schema> provides access to all of the query and iteration goodness of
the excellent DBIx::Class package.  To understand how to tap into all of this
you will want to be familiar with <DBI>, <DBIx::Class>, and to a lesser extent
<SQL::Abstract>.  All of those projects are well documented on CPAN.

This particular module doesn't really do much execpt provide a base class
the modules below it, and load them up.  One additional function provided here
is to load GAL::SchemaAnnotation which provides a single method 'annotation'
so that each feature constructed by DBIx::Class can have access to a weakened
copy of the GAL::Annotation object that is managing it.

=cut
=head1 DIAGNOSTICS

This package does not throw any errors or warnings itself.  If you are
getting errors that seem like they are coming from here, they are probably
being thrown by <DBIx::Class>.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<DBIx::Class::Schema>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::List - List aggregation and analysis functions for GAL

=head1 VERSION

This document describes GAL::List version 0.2.0

=head1 SYNOPSIS

    use GAL::List::Categorical;
    my $list_catg = GAL::List::Categorical->new(list => [qw(red red red blue blue
							       green yellow orange orange
							       purple purple purple purple)]);
    my $count    = $list_catg->count;
    $list_ref    = $list_catg->list;
    @list_ary    = $list_catg->list;
    $class       = $list_catg->class;
    $catg_counts = $list_catg->category_counts;
    $count_uniq  = $list_catg->count_uniq;
    $max_str     = $list_catg->maxstr;
    $min_str     = $list_catg->minstr;
    @shff_list   = $list_catg_shuffle;
    @uniq_list   = $list_catg_uniq;
    $item        = $list_catg->random_pick;

    use GAL::List::Numric;
    $list_numeric = GAL::List::Numeric->new(list => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    $max = $list_numeric->max;
    $min = $list_numeric->min;
    $sum = $list_numeric->sum;

=head1 DESCRIPTION

<GAL::List> serves as a base class for the modules below it and
provides basic list summarization details.  It is not intended to be
used on it's own.  You should use it's subclasses instead.

=head1 CONSTRUCTOR

To construct a GAL::List subclass simply pass it an appropriate list.

    my $list_catg = GAL::List::Categorical->new(list => [qw(red red red blue blue
							       green yellow orange orange
							       purple purple purple purple)]);
    $list_numeric = GAL::List::Numeric->new(list => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);


=cut
=head2 new

     Title   : new
     Usage   : GAL::List->new()
     Function: Creates a GAL::List object;
     Returns : A GAL::List object
     Args    :

=cut
=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor as a
list (or referenece) of key value pairs.

=head2 list

 Title   : list
 Usage   : $a = $self->list()
 Function: Get/Set the value of list.
 Returns : The value of list.
 Args    : A value to set list to.

=cut
=head1 METHODS

=head2 count

 Title   : count
 Usage   : $a = $self->count()
 Function: Get/Set the value of count.
 Returns : The value of count.
 Args    : A value to set count to.

=cut
=head2 count_uniq

 Title   : count_uniq
 Usage   : $a = $self->count_uniq()
 Function:
 Returns :
 Args    :

=cut
=head2 category_counts

 Title   : category_counts
 Usage   : $a = $self->category_counts()
 Function: Get/Set the value of category_counts.
 Returns : The value of category_counts.
 Args    : A value to set category_counts to.

=cut
=head2 max

 Title   : max
 Usage   : $a = $self->max()
 Function:
 Returns :
 Args    :

=cut
=head2 maxstr

 Title   : maxstr
 Usage   : $a = $self->maxstr()
 Function:
 Returns :
 Args    :

=cut
=head2 min

 Title   : min
 Usage   : $a = $self->min()
 Function:
 Returns :
 Args    :

=cut
=head2 minstr

 Title   : minstr
 Usage   : $a = $self->minstr()
 Function:
 Returns :
 Args    :

=cut
=head2 shuffle

 Title   : shuffle
 Usage   : $a = $self->shuffle()
 Function:
 Returns :
 Args    :

=cut
=head2 sum

 Title   : sum
 Usage   : $a = $self->sum()
 Function:
 Returns :
 Args    :

=cut
=head2 uniq

 Title   : uniq
 Usage   : $a = $self->uniq()
 Function:
 Returns :
 Args    :

=cut
=head2 random_pick

 Title   : random_pick
 Usage   : $a = $self->random_pick()
 Function:
 Returns :
 Args    :

=cut
=head1 DIAGNOSTICS

=over

=item C<< list_or_reference_required >>

GAL::List::list require an array or a reference to any array be passed
as an argument, but you have passed something else.

Keep in mind that several of GAL::List's methods are provided by
List::Util, and errors not found here may be thrown by that module.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::List> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Base>
<List::Util>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Feature - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Feature version 0.2.0

=head1 SYNOPSIS

     use GAL::Feature;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut
=head2 new

     Title   : new
     Usage   : GAL::Feature->new();
     Function: Creates a GAL::Feature object;
     Returns : A GAL::Feature object
     Args    :

=cut
=head2 seqid

 Title   : seqid
 Usage   : $self->seqid();
 Function: Get/Set value of seqid.
 Returns : Value of seqid.
 Args    : Value to set seqid to.

=cut
=head2 source

 Title   : source
 Usage   : $self->source();
 Function: Get/Set value of source.
 Returns : Value of source.
 Args    : Value to set source to.

=cut
=head2 type

 Title   : type
 Usage   : $self->type();
 Function: Get/Set value of type.
 Returns : Value of type.
 Args    : Value to set type to.

=cut
=head2 start

 Title   : start
 Usage   : $self->start();
 Function: Get/Set value of start.
 Returns : Value of start.
 Args    : Value to set start to.

=cut
=head2 end

 Title   : end
 Usage   : $self->end();
 Function: Get/Set value of end.
 Returns : Value of end.
 Args    : Value to set end to.

=cut
=head2 score

 Title   : score
 Usage   : $self->score();
 Function: Get/Set value of score.
 Returns : Value of score.
 Args    : Value to set score to.

=cut
=head2 strand

 Title   : strand
 Usage   : $self->strand();
 Function: Get/Set value of strand.
 Returns : Value of strand.
 Args    : Value to set strand to.

=cut
=head2 phase

 Title   : phase
 Usage   : $self->phase();
 Function: Get/Set value of phase.
 Returns : Value of phase.
 Args    : Value to set phase to.

=cut
=head2 attributes

 Title   : attributes
 Usage   : $self->attributes();
 Function: Get/Set value of attributes.
 Returns : Value of attributes.
 Args    : Value to set attributes to.

=cut
=head2 id

 Title   : id
 Usage   : $self->id();
 Function: Get value of id.
 Returns : Value of id.
 Args    : N/A

=cut
=head2 name

 Title   : name
 Usage   : $self->name();
 Function: Get value of name.
 Returns : Value of name.
 Args    : N/A

=cut
=head2 alias

 Title   : alias
 Usage   : $self->alias();
 Function: Get value of alias.
 Returns : Value of alias.
 Args    : N/A

=cut
=head2 parent

 Title   : parent
 Usage   : $self->parent();
 Function: Get the parent.
 Returns : List of parent IDs.
 Args    : N/A

=cut
=head2 target

 Title   : target
 Usage   : $self->target();
 Function: Get value of target.
 Returns : Value of target.
 Args    : N/A

=cut
=head2 gap

 Title   : gap
 Usage   : $self->gap();
 Function: Get value of gap.
 Returns : Value of gap.
 Args    : N/A

=cut
=head2 derives_from

 Title   : derives_from
 Usage   : $self->derives_from();
 Function: Get value of derives_from.
 Returns : Value of derives_from.
 Args    : N/A

=cut
=head2 note

 Title   : note
 Usage   : $self->note();
 Function: Get value of note.
 Returns : Value of note.
 Args    : N/A

=cut
=head2 dbxref

 Title   : dbxref
 Usage   : $self->dbxref();
 Function: Get value of dbxref.
 Returns : Value of dbxref.
 Args    : N/A

=cut
=head2 ontology_term

 Title   : ontology_term
 Usage   : $self->ontology_term();
 Function: Get value of ontology_term.
 Returns : Value of ontology_term.
 Args    : N/A

=cut
=head2 get_attribute_tags

 Title   : get_attribute_tags
 Usage   : $self->get_attribute_tags();
 Function: Get tags of attributes.
 Returns : List of attribute tags.
 Args    : N/A

=cut
=head2 get_attribute_values

 Title   : get_attribute_values
 Usage   : $self->get_attribute_values($tag);
 Function: Get the values of the attribute $tag
 Returns : A list of values.
 Args    : N/A

=cut
=head2 has_attribute_value

 Title   : has_attribute_value
 Usage   : $self->has_attribute_value($tag, $value);
 Function: Get the values of the attribute $tag
 Returns : A list of values.
 Args    : N/A

=cut
=head2 to_gff3

 Title   : to_gff3
 Usage   : print $self->to_gff3();
 Function: Print the feature in GFF3 format
 Returns : The feautre stringified in a GFF3 format.
 Args    : N/A

=cut
=head2 children

 Title   : children
 Usage   : $self->children($type);
 Function: Get this feature's immediate children
 Returns : A list of Feature objects
 Args    : Optionally a valid SO term(s) (scalar or array ref) defining what
           type(s) of children to return.

=cut
=head2 children_recursive

 Title   : children_recursive
 Usage   : $self->children_recursive($type);
 Function: Get this feature's children recursively.
 Returns : A list of Feature objects
 Args    : Optionally a valid SO term(s) (scalar or array ref) defining what
           type(s) of children to return.

=cut
=head2 parents_recursive

 Title   : parents_recursive
 Usage   : $self->parents_recursive($type);
 Function: Get this feature's parents recursively.
 Returns : A list of Feature objects
 Args    : Optionally a valid SO term(s) (scalar or array ref) defining what
           type(s) of parent to return.

=cut
=head1 DIAGNOSTICS

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Feature> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Index - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Index version 0.2.0

=head1 SYNOPSIS

     use GAL::Index;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut
=head2 new

     Title   : new
     Usage   : GAL::Index->new()
     Function: Creates a Index object;
     Returns : A Index object
     Args    :

=cut
=head2 attribute

 Title   : attribute
 Usage   : $a = $self->attribute()
 Function: Get/Set the value of attribute.
 Returns : The value of attribute.
 Args    : A value to set attribute to.

=cut
=head2 method

 Title   : method
 Usage   : $a = $self->method()
 Function: Get/Set the value of method.
 Returns : The value of method.
 Args    : A value to set method to.

=cut
=head1 DIAGNOSTICS

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Index> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Parser::gff3 - Parse GFF3 files

=head1 VERSION

This document describes GAL::Parser::gff3 version 0.2.0

=head1 SYNOPSIS

    my $parser = GAL::Parser::gff3->new(file => 'feature.gff3');

    while (my $feature_hash = $parser->next_feature_hash) {
	print $parser->to_gff3($feature_hash) . "\n";
    }

=head1 DESCRIPTION

<GAL::Parser::gff3> provides GFF3 parsing ability for the GAL library.

=head1 Constructor

New GAL::Parser::gff3 objects are created by the class method
new.  Arguments should be passed to the constructor as a list (or
reference) of key value pairs.  All attributes of the Parser object
can be set in the call to new. An simple example
of object creation would look like this:

    my $parser = GAL::Parser::gff3->new(file => 'data/feature.gff3');

The constructor recognizes the following parameters which will set the
appropriate attributes:

=item * C<< file => feature_file.txt >>

This optional parameter provides the filename for the file containing
the data to be parsed. While this parameter is optional either it, or
the following fh parameter must be set.

=item * C<< fh => feature_file.txt >>

This optional parameter provides a filehandle to read data from. While
this parameter is optional either it, or the following fh parameter
must be set.

=cut
=head2 new

     Title   : new
     Usage   : GAL::Parser::gff3->new();
     Function: Creates a GAL::Parser::gff3 object;
     Returns : A GAL::Parser::gff3 object
     Args    :

=cut
=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash (or reference) of feature data.
 Args    : A hash reference of feature data from the reader

=cut
=head2 parse_attributes

 Title   : parse_attributes
 Usage   : $a = $self->parse_attributes($attrb_text);
 Function: Parse the attributes from column 9 in a GFF3 file.
 Returns : A hash (or reference) of tag/value(s) pairs.  Values are always
           array references even if they are only a single value.
           For example %attributes = (tag => [$value]);
 Args    : The text from column 9 in a GFF3 file.

=cut
=head2 reader

 Title   : reader
 Usage   : $a = $self->reader
 Function: Return the reader object.
 Returns : A GAL::Reader::DelimitedLine singleton.
 Args    : None

=cut
=head1 DIAGNOSTICS

<GAL::Parser::gff3> does not throw any warnings or errors.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Parser::gff3> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Parser>
<GAL::Reader::DelimitedLine>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Reader::DelimitedLine -  Delimited file parsing for GAL

=head1 VERSION

This document describes GAL::Reader::DelimitedLine version 0.2.0

=head1 SYNOPSIS

    use GAL::Reader::DelimitedLine;
    $reader = GAL::Reader::DelimitedLine->new();
    $reader->file('annotation_file.gff');
    $reader->field_names(qw(seqid source type start end score strand phase
			   attributes));
    $reader->next_record, '$reader->next_record');

=head1 DESCRIPTION

<GAL::Reader::DelimitedLine> provides delimited file (tab delimited, csv etc.)
reading capability to GAL.  It is not intended for general library use, but
rather as a GAL::Reader subclass for developers of GAL::Parser subclasses.
There is however no reason why it couldn't also be used as a stand alone
module for other purposes.

=head1 CONSTRUCTOR

New GAL::Reader::DelimitedLine objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  All attributes of the Reader object can be set in
the call to new. An simple example of object creation would look like
this:

  $reader = GAL::Reader::DelimitedLine->new(field_names => \@field_names);

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< field_names => [qw(seqid source type start end)] >>

This optional attribute provides an orderd list that describes the
field names of the columns in the delimited file.  If this attribute
is set then a call to next_record will return a hash (or reference)
with the given field names as keys, otherwise next_record will
return an array of column values.

The following attributes are inhereted from GAL::Reader:

=item * C<< file => feature_file.txt >>

This optional parameter defines what file to parse. While this
parameter is optional either it, or the following fh parameter must be
set before the first call to next_record.

=item * C<< fh => $FH >>

This optional parameter provides a file handle to parse. While this
parameter is optional, either it or the previous must be set before
the first call to next_record.

=back

=cut
=head2 new

     Title   : new
     Usage   : $reader = GAL::Reader::DelimitedLine->new();
     Function: Creates a GAL::Reader::DelimitedLine object;
     Returns : A GAL::Reader::DelimitedLine object
     Args    : field_names => [qw(seqid source type)]
	       file => $file_name
	       fh   => FH
=cut
=head1 ATTRIBUTES

All attributes can be supplied as parameters to the GAL::Annotation
constructor as a list (or referenece) of key value pairs.

=head2 field_names

 Title   : field_names
 Usage   : $reader = $self->field_names([qw(seqid source type)]);
 Function: Set the names for the columns in the delimited text.  If this
	   attribute is set then next_record will return a hash (or reference)
	   otherwise it will return an array (or reference).
 Returns : The next record from the reader.
 Args    : N/A

=cut
=head1 METHODS

=head2 next_record

 Title   : next_record
 Usage   : $record = $reader->next_record();
 Function: Return the next record from the reader
 Returns : The next record from the reader as a hash, array or reference
	   to one of those.  If feild_names is set then a hash will be
	   returned, otherwise an array.
 Args    : N/A

=cut
=head1 DIAGNOSTICS

<GAL::Reader::DelimitedLine> does not throw any error or warnings.  If
errors or warnings appear to be coming from GAL::Reader::Delimited it may be
that they are being throw by <GAL::Reader>

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Reader::DelimitedLine> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Reader>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Reader::RecordParser - Record Parsing using Text::RecordParser

=head1 VERSION

This document describes GAL::Reader::RecordParser version 0.2.0

=head1 SYNOPSIS

    use GAL::Reader::RecrodParser
    $reader = GAL::Reader::RecrodParser->new(file => 'annotation_file.txt',
					     record_separator => "\n",
					     field_separator  => "\t",
					     bind_fields => [qw(seqid source
								type start end
								score strand
								phase attrb
								)
							    ],
					    );
    $reader->next_record, '$reader->next_record');

=head1 DESCRIPTION

<GAL::Reader::RecordParser> provides flexible record reading via
Text::RecordParser.  It is not intended for general library use, but
rather as a GAL::Reader subclass for developers of GAL::Parser
subclasses.  There is however no reason why it couldn't also be used
as a stand alone module for other purposes.

=head1 CONSTRUCTOR

New GAL::Reader::RecordParser objects are created by the class method new.
Arguments should be passed to the constructor as a list (or reference)
of key value pairs.  All attributes of the Reader object can be set in
the call to new. An simple example of object creation would look like
this:

    $reader = GAL::Reader::RecrodParser->new(file => 'annotation_file.txt',
					     record_separator => "\n",
					     field_separator  => "\t",
					     bind_fields => [qw(seqid source
								type start end
								score strand
								phase attrb
								)
							    ],
					    );

The constructor recognizes the following parameters which will set the
appropriate attributes:

=over 4

=item * C<< record_separator >>

This optional parameter defines the pattern by which records are
separated.  The default is a new line.

=item * C<< field_separator >>

This optional parameter defines the pattern by which fields are
separated.  The default is a comma.

=item * C<< comment >>

This optional parameter defines the pattern by which comment lines
are identified.

=item * C<< bind_fields => [qw(seqid source type start end)] >>

This attribute provides an orderd list that describes the field names
of the columns in the delimited file.  If this attribute is not set then
Text::RecordParser will automatically assume that the first line of text
in the file are headers.

=cut
=head2 new

     Title   : new
     Usage   : GAL::Reader::RecordParser->new();
     Function: Creates a GAL::Reader::RecordParser object;
     Returns : A GAL::Reader::RecordParser object
     Args    :

=cut
=head2 record_separator

 Title   : record_separator
 Usage   : $a = $self->record_separator("\n");
 Function: Gets/set the pattern to use as the record separator.
 Returns : The pattern to use as the record separator.
 Args    : The pattern to use as the record separator.

=cut
=head2 field_separator

 Title   : field_separator
 Usage   : $a = $self->field_separator("\t");
 Function: Gets/set the pattern to use as the field separator.
 Returns : The pattern to use as the field separator.
 Args    : The pattern to use as the field separator.

=cut
=head2 comment

 Title   : comment
 Usage   : $a = $self->comment(qr/^#/);
 Function: Takes a regex to apply to a record to see if it looks like a
	   comment to skip.
 Returns : The stored regular expression
 Args    : A regex to apply to a record to see if it looks like a
	   comment to skip.

=cut
=head2 bind_fields

 Title   : bind_fields
 Usage   : $a = $self->bind_fields();
 Function: Takes an array of field names to use as the key values when
	   a hash is returned from C<next_record>.
 Returns : The array reference of field names used as key values for hashes
	   returned by C<next_record>.
 Args    : An array of field names to use as the key values for hashes
	   returned from C<next_record>.

=cut
=head2 _external_reader

 Title   : _external_reader
 Usage   : $a = $self->_external_reader();
 Function: Get the external_reader.
 Returns : A Text::RecordParser object as a singleton.
 Args    : None

=cut
=head2 next_record

 Title   : next_record
 Usage   : $a = $self->next_record();
 Function: Return the next record from the _external_reader
 Returns : The next record from the _external_reader.
 Args    : N/A

=cut
=head1 DIAGNOSTICS

This module does not throw any errors or warning messages.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Reader::RecordParser> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Reader>
<Text::RecordParser>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Feature - Base class for all sequence features

=head1 VERSION

This document describes GAL::Schema::Result::Feature version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
     		            mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
      my $cdss = $mrna->CDSs;
      while (my $cds = $cdss->next) {
	my $cds   = $cds->feature_id;
	my $start = $cds->start;
	my $end   = $cds->end;
      }
    }

=head1 DESCRIPTION

<GAL::Schema::Result::Feature> is the base class for all sequence
feature classes in the GAL's <DBIx::Class> based feature retrival
system.  You don't instantiate objects from it or any of it's
subclasses yourself, <DBIx::Class> does that for you, hence there is
no constructor and there are no attributes available, but you will
want to have a look at the methods as they provide the base
functionality for all sequence feature subclasses.  to all subclasses
as well.  The first 8 methods provide access to the features primary
data as defined by the first 8 columns of GFF3
(http://www.sequenceontology.org/).

=head1 METHODS

=cut
=head2 seqid

 Title   : seqid
 Usage   : $seqid = $self->seqid
 Function: Get the features sequence ID (i.e. what chromosome/contig it's on).
 Returns : The value of the sequence ID as text.
 Args    : None

=cut
=head2 source

 Title   : source
 Usage   : $source = $self->source
 Function: Get the features source.
 Returns : The value of the source as text.
 Args    : None

=cut
=head2 type

 Title   : type
 Usage   : $type = $self->type
 Function: Get the features type - a value constrained to be a child of the
           SO's sequence feature term.
 Returns : The value of the type as text.
 Args    : None

=cut
=head2 start

 Title   : start
 Usage   : $start = $self->start
 Function: Get the features start on the sequence described by seqid.
 Returns : The value of the start an integer.
 Args    : None

=cut
=head2 end

 Title   : end
 Usage   : $end = $self->end
 Function: Get the features end on the sequence described by seqid.
 Returns : The value of the end as an integer.
 Args    : None

=cut
=head2 score

 Title   : score
 Usage   : $score = $self->score
 Function: Get the features score.
 Returns : The value of the score as text.
 Args    : None

=cut
=head2 strand

 Title   : strand
 Usage   : $strand = $self->strand
 Function: Get the features strand.
 Returns : The value of the strand as text.
 Args    : None

=cut
=head2 phase

 Title   : phase
 Usage   : $phase = $self->phase
 Function: Get the features phase.
 Returns : The value of the phase as text.
 Args    : None

=cut
=head2 attributes_hash

 Title   : attributes_hash
 Usage   : $self->attributes_hash
 Function: Return the attributes as a hash (or reference) with all values as
           array references.  For consistency, even those values, such as ID,
           that can have only one value are still returned as array
           references.
 Returns : A hash or hash reference of attribute key/value pairs.
 Args    : None.

=cut
=head2 attribute_value

 Title   : attribute_value
 Usage   : $self->attribute_value($tag)
 Function: Return the value(s) of a particular attribute as an array or
           reference.  Note that for consistency, values are always returned
           as arrays (or reference) even in cases where only a single value
           could exist such as ID.
 Returns : An array or reference of values.
 Args    : None

=cut
=head2 feature_seq

 Title   : feature_seq
 Usage   : $self->feature_seq
 Function: Returns the features sequence as text 5' to 3' in the context of
           the feature, so features on the reverse strand are reverse
           complimented.
 Returns : A text string of the features sequence.
 Args    : None

=head2 seq

An alias for feature_seq

=cut
=head2 genomic_seq

 Title   : genomic_seq
 Usage   : $self->genomic_seq
 Function: Returns the features sequence as text 5' to 3' in the context of
           the genome, so features on the reverse strand are not reverse
           complimented.
 Returns : A text string of the features sequence on the genome.
 Args    : None

=cut
=head2 length

 Title   : length
 Usage   : $self->length
 Function: Returns the features length on the genome.  If a feature is
           not contiguous on the genome (i.e. a transcript) then this method
           will be (or should be) overridden by that subclass to provide the
           'spliced' length of that feature.
 Returns : An integer.
 Args    : None

=cut
=head2 genomic_length

 Title   : genomic_length
 Usage   : $self->genomic_length
 Function: Returns the features genomic_length on the genome.  If a feature is
           not contiguous on the genome (i.e. a transcript) then this method
           will still provide the genomic length of (end - start + 1)
 Returns : An integer.
 Args    : None

=cut
=head2 annotation

 Title   : annotation
 Usage   : $self->annotation
 Function: Each feature has a weakened reference of the GAL::Annotation
           object that created it and this method provides access to that
           object.
 Returns : A GAL::Annotation object.
 Args    : None

=cut
=head1 DIAGNOSTICS

=item C<< GAL::Schema::Result::Feature::feature_bins is deprecated.  We
should be using the method in GAL::Base instead.  Please update your code
and stop using it. >>

The error message pretty much says it all.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Feature> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<DBIx::Class>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Attribute - Access to feature attributes for GAL::Schema::Result::Features

=head1 VERSION

This document describes GAL::Schema::Result::Attribute version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
	my $attributes = $mrnas->attributes->all;
      }
    }


=head1 DESCRIPTION

<GAL::Schema::Result::Attribute> provides access to a
<GAL::Schema::Result::Feature>'s attributes.  You don't instantiate
objects for it yourself, <DBIx::Class> does that for you, hence there
is no constructor and there are no attributes available and currently there
are no methods except those provided by DBIx::Class.

=cut
=head1 METHODS

=head2 subject_id

 Title   : subject_id
 Usage   : $seqid = $self->subject_id;
 Function: Get the attributes subject_id.
 Returns : A text string for the subject_id.
 Args    : None

=head2 attribute_id

 Title   : attribute_id
 Usage   : $seqid = $self->attribute_id;
 Function: Get the attributes attribute_id.
 Returns : A text string for the attribute_id.
 Args    : None

=head2 feature_id

 Title   : feature_id
 Usage   : $seqid = $self->feature_id;
 Function: Get the attributes feature_id.
 Returns : A text string for the feature_id.
 Args    : None

=head2 att_key

 Title   : att_key
 Usage   : $seqid = $self->att_key;
 Function: Get the attributes key.
 Returns : A text string for the key.
 Args    : None

=head2 subject

 Title   : att_value
 Usage   : $seqid = $self->att_value;
 Function: Get the attributes value(s)
 Returns : A text string for the value(s) as a comma seperated list.
 Args    : None

=head1 DIAGNOSTICS

This module currently throws no errors or warnings.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Attribute> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<DBIx::Class>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Relationship - Access to relationships for <GAL::Schema::Result::Feature> objects.

=head1 VERSION

This document describes GAL::Schema::Result::Relationship version 0.2.0

=head1 SYNOPSIS

    my $exons = $self->children->search({type => 'exon'});
    my $transcripts = $self->parents->search({type => 'mRNA'});

=head1 DESCRIPTION

The GAL::Schema::Result::Relationship class is not intended for public
used by GAL::Schema::Result::Feature to find parents and children of
features.

=cut
=head1 METHODS

=head2 subject_id

 Title   : subject_id
 Usage   : $subject_id = $self->subject_id
 Function: Get the features subject_id.
 Returns : The value of the subject_id as text.
 Args    : None

=head2 parent

 Title   : parent
 Usage   : $parent = $self->parent
 Function: Get the features parent.
 Returns : The value of the parent as text.
 Args    : None

=head2 child

 Title   : child
 Usage   : $child = $self->child
 Function: Get the features child.
 Returns : The value of the child as text.
 Args    : None

=head2 relationship

 Title   : relationship
 Usage   : $relationship = $self->relationship
 Function: Get the features relationship.
 Returns : The value of the relationship as text.
 Args    : None
 Note    : The relationship column in the GAL schema - and
           hence this method - are not currently in use.
           They are here for future developement.

=head1 DIAGNOSTICS

<GAL::Schema::Result::Relationship> currently throws no errors or warning messages.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Relationship> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<DBIx::Class>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Feature::gene -  A gene object for the GAL Library

=head1 VERSION

This document describes GAL::Schema::Result::Feature::gene version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $genes = $features->search({type => 'gene'});
    while (my $gene = $genes->next) {
      my $mrnas = $gene->mRNAs;
      while (my $mrna = $mrnas->next) {
	my $id    = $mrna->feature_id;
	my $start = $mrna->start;
	my $end   = $mrna->end;
      }
    }

=head1 DESCRIPTION

<GAL::Schema::Result::Feature::gene> provides a <GAL::Schema::Result::Feature>
subclass for gene specific behavior.

=head1 METHODS

=cut
=head2 transcripts

 Title   : transcripts
 Usage   : $transcripts = $self->transcripts
 Function: Get the genes transcript features
 Returns : A DBIx::Class::Result object loaded up with transcripts.
 Args    : None

=cut
=head2 mRNAs

 Title   : mRNAs
 Usage   : $mRNAs = $self->mRNAs
 Function: Get the genes mRNA features
 Returns : A DBIx::Class::Result object loaded up with mRNA features.
 Args    : None

=cut
=head1 DIAGNOSTICS

This module does not throw any error or warning messages.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Feature::gene> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Schema::Result::Feature::sequence_feature>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Feature::transcript - A transcript object for the GAL
Library

=head1 VERSION

This document describes GAL::Schema::Result::Feature::transcript
version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $genes = $features->search({type => 'gene'});
    while (my $gene = $genes->next) {
      my $transcripts = $gene->transcripts;
      while (my $transcript = $transcripts->next) {
	my $id    = $transcript->feature_id;
	my $start = $transcript->start;
	my $end   = $transcript->end;
      }

    }

=head1 DESCRIPTION

<GAL::Schema::Result::Feature::transcript> provides a <GAL::Schema::Result::Feature>
subclass for transcript specific behavior.

=head1 METHODS

=cut
=head2 exons

 Title   : exons
 Usage   : $exons = $self->exons
 Function: Get the features exons
 Returns : A DBIx::Class::Result object loaded up with exons
 Args    : None

=cut
=head2 introns

 Title   : introns
 Usage   : $introns = $self->introns
 Function: Get the features introns
 Returns : A DBIx::Class::Result object loaded up with introns
 Args    : None

=cut
=head2 three_prime_UTRs

 Title   : three_prime_UTRs
 Usage   : $three_prime_UTRs = $self->three_prime_UTRs
 Function: Get the features three_prime_UTRs
 Returns : A DBIx::Class::Result object loaded up with three_prime_UTRs
 Args    : None

=cut
=head2 five_prime_UTRs

 Title   : five_prime_UTRs
 Usage   : $five_prime_UTRs = $self->five_prime_UTRs
 Function: Get the features five_prime_UTRs
 Returns : A DBIx::Class::Result object loaded up with five_prime_UTRs
 Args    : None

=cut
=head2 mature_seq_genomic

 Title   : mature_seq_genomic
 Usage   : $seq = $self->mature_seq_genomic
 Function: Get the transcripts spliced genomic sequence (not reverse
	   complimented for minus strand features).
 Returns : A text string of the transcripts splice genomic sequence.
 Args    : None

=cut
=head2 mature_seq

 Title   : mature_seq
 Usage   : $seq = $self->mature_seq
 Function: Get the transcripts spliced sequence reverse complimented for minus
	   strand features.
 Returns : A text string of the transcripts splice genomic sequence.
 Args    : None

=cut
=head2 five_prime_UTR_seq_genomic

 Title   : five_prime_UTR_seq_genomic
 Usage   : $seq = $self->five_prime_UTR_seq_genomic
 Function: Get the transcripts spliced five_prime_UTR genomic sequence (not
	   reverse complimented for minus strand features.
 Returns : A text string of the five_prime_UTR spliced genomic sequence.
 Args    : None

=cut
=head2 five_prime_UTR_seq

 Title   : five_prime_UTR_seq
 Usage   : $seq = $self->five_prime_UTR_seq
 Function: Get the transcripts spliced five_prime_UTR sequence reverse
	   complimented for minus strand features.
 Returns : A text string of the five_prime_UTR spliced sequence.
 Args    : None

=cut
=head2 three_prime_UTR_seq_genomic

 Title   : three_prime_UTR_seq_genomic
 Usage   : $seq = $self->three_prime_UTR_seq_genomic
 Function: Get the transcripts spliced three_prime_UTR genomic sequence (not
	   reverse complimented for minus strand features.
 Returns : A text string of the three_prime_UTR spliced genomic sequence.
 Args    : None

=cut
=head2 three_prime_UTR_seq

 Title   : three_prime_UTR_seq
 Usage   : $seq = $self->three_prime_UTR_seq
 Function: Get the transcripts spliced three_prime_UTR sequence reverse
	   complimented for minus strand features.
 Returns : A text string of the three_prime_UTR spliced sequence.
 Args    : None

=cut
=head2 length

 Title   : length
 Usage   : $length = $self->length
 Function: Get the length of the mature transcript - the sum of all of it's
           exon lengths.
 Returns : An integer
 Args    : None

=cut
=head2 coordinate_map

 Title   : coordinate_map
 Usage   : $map = $self->coordinate_map
 Function: Get the coordinate map the which has the structure:
	   $coordinate_map{genome2me}{$genomic_position}    = $transcript_position;
	   $coordinate_map{me2genome}{$transcript_position} = $genomic_position;
	   And thus can be used to map feature to genomic coordinates and vice versa.
 Returns : A hash or reference of the above map.
 Args    : None

=cut
=head2 genome2me

 Title   : genome2me
 Usage   : $my_coordinates = $self->genome2me(@genome_coordinates);
 Function: Transform genomic coordinates to mature transcript coordinates.
 Returns : An array or reference of mature transcript coordinates.
 Args    : An array reference of genomic coordinates.

=cut
=head2 me2genome

 Title   : me2genome
 Usage   : $genomic_coordinates = $self->me2genome(@my_coordinates);
 Function: Transform mature transcript coordinates to genomic coordinates.
 Returns : An array or reference of genomic coordinates.
 Args    : An array reference of mature transcript coordinates.

=cut
=head1 DIAGNOSTICS

<GAL::Schema::Result::Feature::transcript> does not throw any warnings
or error messages.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Feature::transcript> requires no configuration
files or environment variables.

=head1 DEPENDENCIES

<GAL::Schema::Result::Feature::sequence_feature>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Feature::exon -  A exon object for the GAL Library

=head1 VERSION

This document describes GAL::Schema::Result::Feature::exon version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
      my $exons = $mrna->exons;
      while (my $exon = $exons->next) {
	my $id    = $exon->feature_id;
	my $start = $exon->start;
	my $end   = $exon->end;
      }
    }

=head1 DESCRIPTION

<GAL::Schema::Result::Feature::exon> provides a <GAL::Schema::Result::Feature>
subclass for exon specific behavior.

=head1 METHODS

There are currenlty no exon specific methods implimented for
<GAL::Schema::Result::Feature::exon>.  See <GAL::Schema::Result::Feature>
for inhereted methods.

=cut
=head1 DIAGNOSTICS

There are currently no errors or warnings thrown by
<GAL::Schema::Result::Feature::exon>.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Feature::exon> requires no configuration files
or environment variables.

=head1 DEPENDENCIES

<GAL::Schema::Result::Feature::sequence_feature>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All
rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut=head1 NAME

GAL::Schema::Result::Feature::cds - A CDS object for the GAL Library

=head1 VERSION

This document describes GAL::Schema::Result::Feature::cds version 0.2.0

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
      my $cdss = $mrna->CDSs;
      while (my $cds = $cdss->next) {
	my $id    = $cds->feature_id;
	my $start = $cds->start;
	my $end   = $cds->end;
      }
    }

=head1 DESCRIPTION

<GAL::Schema::Result::Feature::cds> provides a <GAL::Schema::Result::Feature>
subclass for CDS specific behavior.

=head1 METHODS

There are currenlty no CDS specific methods implimented for
<GAL::Schema::Result::Feature::cds>.  See <GAL::Schema::Result::Feature>
for inhereted methods.

=cut
=head1 DIAGNOSTICS

There are currently no errors or warnings thrown by <GAL::Schema::Result::Feature::cds>

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Feature::cds> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Schema::Result::Feature::sequence_feature>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
