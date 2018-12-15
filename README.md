# tomato
Tomato Language Compiler

# Completed
- Lexer
- Parser
- Semantic Analyser
- Code Generator: NFA
- Executor (see below): NFA

# TODO
- Code Generator: NPDA, NDTM
- Executor (see below): NPDA, NDTM
- Debug tools: break-states (seeing tape/stack contents)

# Executor
Have a server goroutine and multiple worker goroutines. The server maintains a queue of unfinished jobs. The server contains a serve loop (like CSO: see below) and doles out unfinished jobs to the worker goroutines. The worker goroutines have a serve loop where they receive a job, work on it, and return it back to the server (for it to put in its queue). 

# Serve loop
Maintain an array of k channels real_chans, and an array of k boolean functions guards, as well as an initially empty array of k channels chans.

```
for {
  for i := 0, i < k, i++ {
    if guard[i] {
      chans[i] = real_chans[i]
    } else {
      chans[i] = nil
    }
  }
  select {
    case x := <- chans[0]:
      //code for first channel
    case chans[1] <- x:
      //code for second channel      
    ...
  }
}
