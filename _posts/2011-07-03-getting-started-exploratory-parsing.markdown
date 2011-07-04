---
layout: default
author: ward
synopsis: A parser reads text to discover structure and meaning. For example, a C language parser can read a C program and understand in a real sense everything that the program has to say. Contrast this to a pattern matcher...
---

A parser reads text to discover structure and meaning. For example, a C
language parser can read a C program and understand in a real sense everything
that the program has to say. Contrast this to a pattern matcher, such as
regular-expression matching, which can find fragments of a program useful in
editing but can't keep track of enough context to make sense of a whole
program.

We often use the unix grep utility to look through large files. By applying a
regular-expression match to each line, grep is able to report just the lines of
interest. When we allow ourselves to grep repeatedly, driven by our curiosity,
responding to each answer grep provides with another question, when we do this
we are exploring.

The internet is full of text that defies understanding in any sense with simple
pattern matching. In response AboutUs built an environment for exploring the
internet interactively, using parsers constructed on a whim, returning matches
in within the context described by the explorer.


Exploring the World Fact Book
--

The AboutUs exploratory parsing environment has been released as open source on
GitHub. Included with the release are scripts to download The World Factbook
and English Wikipedia as sample texts for exploring. Let's take a look at the
Factbook.



When exploring, we start by looking for something that we know is there. We'll
start by looking for short strings of characters without any regard for where
they are.

    char = << ......... >>

Our parser uses a dot (.) to match any character. We say we're looking for a
few of them. And when we find them we want to see them so we add "eye-balls"
around the dots to tell the parser to remember some of the matches.


![](/images/parser/PastedGraphic-14.png)
![](/images/parser/PastedGraphic-5.png)

This says that our parser found over a quarter million matches. When we ask to
see some, it shows us the text on the right. This is just a sample match. When
the sample was taken the text shown in green had been matched, and that
highlighted in yellow is the specific match sampled. This data looks like keys
and values separated by colons.

Let's look for keys and values by describing what we think we know about the
file. We'll offer the parser an alternative for text that isn't key-value pairs
as we understand them.


    fact = key value | other_char
    key = whitespace << word+ >> ':'
    value = << ( !key . )+ >>
    word = [A-Za-z]+ ' '*
    whitespace = '\n' ' '*
    other-char = << . >>


Now we're getting pretty specific as to what we mean by key and value. We say
1) a key starts with whitespace, 2) the key has one or more words, 3) the words
end with a colon, and 4) we only care to have eyeballs on the words of the key.
Is happy to read the whole file.

![](/images/parser/PastedGraphic-1.png)
![](/images/parser/PastedGraphic-6.png)

The parser found 19,498 keys and an equal number of values. Makes sense. When
we look at the sample keys we find a few surprises. Most are capitalized but
not all. The subcategories of Imports are lower case. Interesting. Lets see how
wide spread this convention is.


    key = whitespace << ( upper | lower ) >> ':'
    upper = << [A-Z] word+ >>
    lower = << word+ >>

![](/images/parser/PastedGraphic-2.png)
![](/images/parser/PastedGraphic-10.png)


When we look at some lowers we see the expected "commodities" and "partners"
and one more outlier, the login instructions to get the Factbook from Project
Gutenberg. Let's separate out the familiar to see what other lower-case
keywords might exist.


    lower = << ( familiar | other-key ) >>
    familiar = << ( 'commodities' | 'partners' ) >>
    other-key = << word+ >>

![](/images/parser/PastedGraphic-13.png)
![](/images/parser/PastedGraphic-11.png)

Now we're down to 77 out of 20 thousand keys. Sampling these we see more that
make sense and should be added to the familiar category. We also see a few
places where our parsing rules are clearly not working as intended. We could
tighten up the rules by saying just how much whitespace we expect before a key,
or how many words we expect, or just discover the words that should be familiar
and ignore the rest. We have options.

We also have other branches in our parse to explore. We haven't even begun to
parse the values. We could, for example, select out "Climate" and see how many
ways climate is described in the Factbook. Maybe we do the same for "Terrain".
Maybe we correlate phrases we find within the two and get some insight into how
the two are related. We don't have to just sample parser matches. We can take
the text of interesting matches and feed that into other programs.


Get the Exploratory Parser
--

We've been using a tool made out of two parts, both of them available to other
programmers under AboutUs on GitHub. One is
[our fork](https://github.com/AboutUs/pegleg) of Ian Piumarta's peg/leg parser
generator. The [other](https://github.com/AboutUs/exploratory-parsing) is our
parsing experiment management system.

The parser generator is written in C and could be rough going for programmers
who haven't studied compilers at some point in their lives. We've only modified
peg/leg as we found our unusual approach to parsing was not anticipated by Ian.
Ian provides documentation on his website.

The experiment manager is a web application written in Ruby to run under Mac or
Unix. We run it on our laptops and in Amazon's EC2 cloud. We've described how
we install it in our GitHub ReadMe. Your Mileage May Vary.

Thinking Different
--

We think we've opened up a whole new way to use technology. This can happen
when one takes some assumed requirement and reverse it. Wiki, for example,
reversed the assumption that only the owner should edit the pages of a web
site. Parser generators have traditionally been used to describe exactly what
should be written and anything else is a "syntax error". Wiki allows writers to
write what they think makes sense. With exploratory parsing we now have a way
for the parser writer to discover what has been written after the fact. This
inversion of control mirrors the original thinking behind wiki. Let those who
know write as they see fit. Trust people to be regular enough to create lasting
value. Use the power of our modern computers and networks to organize that
value.
