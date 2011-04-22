---
layout: default
author: ward
synopsis: Sedgewick wants CS students to learn from real data. I give it a try rummaging through the many datasets he offers online in support of his introductory algorithms textbooks. 
published: false
---
Pittsburg University CS Professor Robert Sedgewick suggests students will learn better and stay engaged when writing programs that make sense of real data. I suggested to the newly forming Portland Data Science meetup that we might likewise benefit from exploring data together and gave Sedgewick's state adjacencies as an example. Here is the data and a few lines from the front:

	http://introcs.cs.princeton.edu/data/contiguous-usa.dat

	AL FL
	AL GA
	AL MS
	AL TN
	AR LA
	AR MO
	AR MS 
	...

I saw this when I was reading something else Sedgewick wrote and thought, what would graphviz do with this?

![Contiguous USA Graph](/images/contiguous-usa.png)

It did pretty well, I'd say. In fact it did too well. How did graphviz know that WA was in the northwest? 

You can see that it did get the northeast upside down. That's comforting. I know more about geography than graphviz. 

This raises the question, what little extra bit of information would allow a much better map? Some ideas:

	* the length or orientation of the border
	* the size of the state in square miles
	* the state's voting record

Here is the perl program I used to convert the dataset to dot format:

	@lines = `cat contiguous-usa.txt`;
	open D, ">contiguous-usa.dot";
	print D "graph US {\nnode [style=filled,color=yellow]";
	for (@lines) { print D "$1 -- $2;\n" if /(\w\w) (\w\w)/; }
	print D "}\n";

I consider this kind of programming a warm-up for serious work. But warming up is very important in a field where the opportunities are so diverse.