# marked-graphviz

This is a pre-processor for Marked2.app that

1. Reads in the Markdown
2. Finds <dot> and <neato> blocks
3. Strips them and runs them through dot and neato on the command line, creating files named whatever follows graph/digraph
4. Returns the markdown through stdout with the dot and neato blocks replaced with references to inline images

