# Example #

You're typing along in Markdown when you realize more visual people might prefer a diagram, so you quickly do


<dot>
digraph Example_Graph {
	a->b
	b->c
	c->a
}
</dot>

## Subtest ##

Perhaps using dot isn't your preference and you'd rather neato, which is also available.

<neato>
digraph abc {
	a->b
	b->c
	c->a
}
</neato>

# Requirements

Graphviz installed (available in homebrew) and dot and neato are in your path.