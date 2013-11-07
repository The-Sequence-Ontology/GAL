# Make the docs
pod2projdocs -o GAL/ -l ../../lib/GAL/ -f -t 'GAL' -d 'GAL - The Genome Annotation Library'

# Fix the links
find ./ -name '*.html' | xargs perl -i.bak -ape 's|<a href="http://search.cpan.org/perldoc\?GAL%3A%3A(.+?)">|<a href="$1.pm.html">|g;s|%3A%3A|/|g;'

# Remove backup files
find ./ -name '*.bak' | xargs rm -f
