test_counter = 0

/* Test run_program */
assert_equal(run_program("(+ 1 2)"), "3")
assert_equal(run_program("(+ (+ 1 2) (+ 5 6))"), "14")
assert_equal(run_program("(+ 1 (+ 5 6))"), "12")
assert_equal(run_program("(+ 1 (+ 5 ))"), "Incorrect operator usage")
assert_equal(run_program("(- 3 2)"), "1")
assert_equal(run_program("((func (a b) (+ a b)) 1 2)"), "3")
assert_equal(run_program("((func (a b c) (+ a (+ b c))) 1 2 3)"), "6")

/* Test make_env */
assert_equal(make_env(), "")

/* Test append_env */
assert_equal(append_env(make_env(), "taco", "burrito"), "taco" "burrito")

/* Tests for fetch_env */
assert_equal(fetch_env(append_env(make_env(),"taco", "burrito"), "taco"), "burrito")
assert_equal(fetch_env(append_env(append_env(make_env(), "taco", "burrito"), "cat", "meow"), "cat"), "meow")
assert_equal(fetch_env(append_env(append_env(make_env(), "taco", "burrito"), "cat", "meow"), "meow"), "")
assert_equal(fetch_env(append_env(append_env(append_env(make_env(), "meow", "dog"), "taco", "burrito"), "cat", "meow"), "meow"), "dog")

/* Tests for countSymbol */
assert_equal(countSymbol("())", "("), 1)
assert_equal(countSymbol("())", ")"), 2)
assert_equal(countSymbol("))", "("), 0)
assert_equal(countSymbol("((", ")"), 0)
assert_equal(countSymbol("(abc)123)", "("), 1)
assert_equal(countSymbol("(abc)123)", ")"), 2)

/* Tests for findEndOfExpr */
assert_equal(findEndOfExpr("(+ 1 2) )", 1), 3)
assert_equal(findEndOfExpr("(+ (+ 1 2) (+ 5 6)) 3)", 1), 7)
assert_equal(findEndOfExpr("(+ 1 (+ 5 6)) 5) 7)", 1), 5)
assert_equal(findEndOfExpr("() (5 )) (", 1), 1)
assert_equal(findEndOfExpr("+ 1 2) )", 1), -1)
assert_equal(findEndOfExpr("(+ 1 2", 1), 0)

return

/* Accepts two strings as arguments and compares their values directly and
 * prints to stdout whether or not they are the same. Also accepts a global
 * counter of tests so you can number the testing process.
 * assert_equal(left, right)
 */
assert_equal : procedure expose test_counter
  test_counter = test_counter + 1
  if (compare(arg(1), arg(2)) == 0) then
    say "TEST" test_counter "PASSED:" arg(1) "==" arg(2)
  else
    say "TEST" test_counter "FAILED:" arg(1) "!=" arg(2)
  return ""


/* Returns an empty environment 
 * make_env()
 */
make_env : procedure
  return ""

/* Appends a binding to the environment 
 * append_env(current_env, identifier, value) 
 */
append_env : procedure
  old_env = arg(1)
  id = arg(2)
  val = arg(3)
  return id val old_env

/* Fetches the value of an identifier from the env 
 * fetch_env(current_env, identifier) 
 */
fetch_env : procedure
  current_env = arg(1)
  search_id = arg(2)
  /* perform a search in the env */
  found_pos = Wordpos(search_id, current_env)
  if (found_pos == 0) then
    /* nothing was found */
    return ""
  else do
    if (found_pos // 2 == 0) then do
      /* found a value instead of a key, keep searching */
      return fetch_env(Subword(current_env, found_pos + 1), search_id)
    end
    else
      /* found the desired key and corresponding value */
      return word(current_env, found_pos + 1)
  end

/* Pinterps the input expression and outputs its resultant value.
 * run_program(string)
 */
run_program : procedure
  current_program = arg(1)

  /* Test function to illustrate how functions can be stored. */  
  allfunctions.0.0 = "a b"
  allfunctions.0.1 = "(+ a b)"
  sizeoffunctions = 1

  output = pinterp(1)
  if(output == "") then
    return ""
  else
    return word(pinterp(1), 1)

/* Function that returns the number of times a specified symbol appears in a
 * word.
 * countSymbol(word, symbol)
 */
countSymbol: procedure
  parse arg word, symbol
  length = wordLength(word, 1)
  charIndex = 1
  count = 0

  do while (charIndex <= length)
    char = subStr(word, charIndex, 1)
    if (verify(char, symbol, 'M', 1) == 1) then
      count += 1
    charIndex += 1
  end

  return count

/* Function that takes an expression enclosed in braces as an input argument
 * as well as an index into that string to a word that includes a left open
 * parenthesis. The function then finds the matching right parenthesis and
 * returns its word index to the caller. If no matching right parenthesis is
 * found in the inputString then 0 is returned. If the first word in the input
 * string does not have a left parenthesis then a -1 is returned.
 * findEndOfExpr(inputString, wordIndex)
 */
findEndOfExpr: procedure
  parse arg inputString, startIndex

  /* Check to see if the first word contains a left parenthesis. */
  if (abbrev(inputString, '(', 1) <> 1) then
    return -1

  wordCount = words(inputString)
  wordIndex = startIndex
  matched = 0

  /* Loop until the matching close brace is found. */
  do while (wordIndex <= wordCount)
    word = word(inputString, wordIndex)

    matched += countSymbol(word, "(")
    matched -= countSymbol(word, ")")

    if (matched <= 0) then
      return wordIndex

    wordIndex += 1
  end

  return 0

/* Parses the input string and interprets the results. Currently only binops
 * are supported, with functions being close to being implemented.
 * pinterp(expression)
 */
pinterp : procedure expose current_program allfunctions. sizeoffunctions
  startindex = arg(1)
  /* Get the first symbol at the start index */
  firstsymbol = word(current_program, startindex)

  /* Check the first symbol of the expression */
  parse value firstsymbol with "(" op

  /* If the expression does not start with the '(' symbol */
  if (op == '') then
    do
      /* The expression does not start with the '(' symbol which means that it
       * can't be an operator or a function call */
      nextindex = startindex + 1

      /* Assume it is a number because var lookups aren't implemented. */
      parse value firstsymbol with number ")"

      /* Return the value and the next word index in current_program. */
      return number nextindex
    end
  /* Must be an operator or function call or func keyword. */
  else
    do
      /* Handle the plus operator. */
      if (op == "+") then
        do
          /* Evaluate it's two arguments by calling pinterp. */
          call pinterp startindex + 1
          firstvalue = word(result, 1)
          nextindex = word(result, 2)

          call pinterp nextindex
          secondvalue = word(result, 1)
          nextindex = word(result, 2)

          /* Add the results of the two calls and return the value. */
          newvalue = firstvalue + secondvalue
          return newvalue nextindex
        end
      /* Handle the func keyword. */
      else if (op == "func") then
        do
          /* Parse list of args of the form (func (a b c) */
          firstarg = word(current_program, startindex + 1)
          parse value firstarg with "(" fargname

          /* Check for case where first arg is () and therefore there are no
           * arguments*/
          if (fargname == ")") then
            do
              allfunctions.sizeoffunctions.0 = ""
            end
          /* Otherwise, handle the general function format case. */
          else
            do
              allfunctions.sizeoffunctions.0 = fargname
              argwordindex = startindex + 2

              /* Get the rest of the arg names */
              do forever
                newarg = word(current_program, argwordindex)

                isbrace = verify(newarg, ")", 'M', 1)

                /* If there is an ending brace in this word it means that it is
                 * the end of arglist. */
                if (isbrace <> 0) then
                  do
                    parse value newarg with argname ")"
                    allfunctions.sizeoffunctions.0 =
                        allfunctions.sizeoffunctions.0 argname
                    leave
                  end
                /* Otherwise add not last arg and keep iterating */
                allfunctions.sizeoffunctions.0 =
                    allfunctions.sizeoffunctions.0 newarg
                argwordindex = argwordindex + 1
              end
            end
           /* The rest of func is not implemented */
           return "ERROR:NOT_IMPLEMENTED"
        end
      else
        /* The other operators are not implemented */
        return "ERROR:NOT_IMPLEMENTED"
    end
    return ""
