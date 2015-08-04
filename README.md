# csv2markdown
I noticed that there are a good number of scripts on GitHub to turn a CSV table into Markdown, but none of them
seemed to be using Perl. This is my effort to fix that.

The goal is to keep it pretty simple so it can work on older distributions. No unending package calls. The only
packages that might be included, at the moment are Getop::Long and possibly, should the need arise, Data::Dumper.
