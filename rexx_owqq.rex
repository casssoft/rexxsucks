test_counter = 0
assert_equal(run_program("(+ 1 2)"), "3")
assert_equal(run_program("(+ (+ 1 2) (+ 5 6))"), "14")
assert_equal(run_program("(+ 1 (+ 5 6))"), "12")

assert_equal(run_program("(+ 1 (+ 5 ))"), "Incorrect operator usage")
assert_equal(run_program("(- 3 2)"), "1")

assert_equal(run_program("((func (a b) (+ a b)) 1 2)"), "3")
assert_equal(run_program("((func (a b c) (+ a (+ b c))) 1 2 3)"), "6")

assert_equal(make_env(), "")
assert_equal(append_env(make_env(), "taco", "burrito"), "taco" "burrito")
assert_equal(fetch_env(append_env(make_env(), "taco", "burrito"), "taco"), "burrito")
assert_equal(fetch_env(append_env(append_env(make_env(), "taco", "burrito"), "cat", "meow"), "cat"), "meow")
assert_equal(fetch_env(append_env(append_env(make_env(), "taco", "burrito"), "cat", "meow"), "meow"), "")
assert_equal(fetch_env(append_env(append_env(append_env(make_env(), "meow", "dog"), "taco", "burrito"), "cat", "meow"), "meow"), "dog")

return

assert_equal : procedure expose test_counter
  test_counter = test_counter + 1
  if (compare(arg(1), arg(2)) == 0) then
    say "TEST" test_counter "PASSED:" arg(1) "==" arg(2)
  else
    say "TEST" test_counter "FAILED:" arg(1) "!=" arg(2)
  return ""


/* returns an empty environment 
 */
make_env : procedure
  return ""

/* appends a binding to the environment 
 * append_env(current_env, identifier, value) 
 */
append_env : procedure
  old_env = arg(1)
  id = arg(2)
  val = arg(3)
  return id val old_env

/* fetches the value of an identifier from the env 
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


run_program : procedure
  current_program = arg(1)  
  allfunctions.0.0 = "a b"
  allfunctions.0.1 = "(+ a b)"
  sizeoffunctions = 1
  output = pinterp(1)
  if(output == "") then
    return ""
  else
    return word(pinterp(1), 1)

/*getfullstring : procedure expose current_program
  startindex = arg(1)
  parse firstword
  indentCount = 1
  curindex = startindex + 1
  do forever
    
  verify(newarg, "(", 'M', 1)*/

pinterp : procedure expose current_program allfunctions. sizeoffunctions
  startindex = arg(1)
  say "pinterp: startindex: " startindex
  firstsymbol = word(current_program, startindex)
  parse value firstsymbol with "(" op
  if (op == '') then
    do
      /* or look up in env */
      say "no op, firstsymbol: " firstsymbol
      nextindex = startindex + 1
      say "returning"
      parse value firstsymbol with number ")"
      return number nextindex
    end
  else
    do
      if (op == "+") then
        do
          say "yes plus"
          
          call pinterp startindex + 1
          firstvalue = word(result, 1)
          nextindex = word(result, 2)
          call pinterp nextindex
          secondvalue = word(result, 1)
          nextindex = word(result, 2)
          newvalue = firstvalue + secondvalue
          return newvalue nextindex
        end
      else if (op == "func") then
        do
          say "yes function"
          /* parse list of args*/
          /* (func (a b c) */
          firstarg = word(current_program, startindex + 1)
          parse value firstarg with "(" fargname
          if (fargname == ")") then
            do
              allfunctions.sizeoffunctions.0 = ""
            end
          else
            do
              allfunctions.sizeoffunctions.0 = fargname
              argwordindex = startindex + 2
              do forever
                newarg = word(current_program, argwordindex)
                isbrace = verify(newarg, ")", 'M', 1)
                if (isbrace <> 0) then
                  do
                    parse value newarg with argname ")"
                    allfunctions.sizeoffunctions.0 = allfunctions.sizeoffunctions.0 argname
                    leave
                  end
                allfunctions.sizeoffunctions.0 = allfunctions.sizeoffunctions.0 newarg
                argwordindex = argwordindex + 1
              end
            end
        end
      else
        return "ERROR:NOT_IMPLEMENTED"
    end
    return ""
      
