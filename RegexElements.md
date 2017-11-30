## Literals

## Wildcard Character  `.`

## Character Classes

## Negated Character Classes

## Positional Matching - Anchors  `^` `$`


## Alternation

## Case Insensitive matching

## Word boundaries

## Quantifiers
   + Optional pattern ?
   + Zero or more  *
   + One or more  \+
   + m or more   `{m,}`
   + n or fewer   `{,n}`
   + between m and n  `{m,n}`

## Grouping and Back-References ()
   +  () and \\1, \\2, etc.
   



## Extensions

### Non-greedy Matching
    + Problems with greedy matching.
	+ Common simple case, simple solution
	   + Anything except this character
	   + or any of these characters
    + *?

### Positive Lookahead and Behind
    + (?=  )   (?<= )
	
### Negative Lookahead and Behind
    + (?!  )   (?<! )	
