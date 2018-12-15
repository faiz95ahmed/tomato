package machine

type NFA struct {
  Q0 int
  FinalStates []bool
  StateNames []string
  Transitions []map[rune][]int
}
func GetMachine() *NFA {
  startState := 0
  finalStatesSlice := []bool{false, false, false, true}
  stateNamesSlice := []string{"x", "y", "z", "f"}
  var transitionsArray [4]map[rune][]int
  transitionsArray[0] = make(map[rune][]int)
  transitions0a := []int{1}
  transitionsArray[0]['a'] = transitions0a
  transitions0b := []int{0}
  transitionsArray[0]['b'] = transitions0b
  transitions0c := []int{0}
  transitionsArray[0]['c'] = transitions0c
  transitionsArray[1] = make(map[rune][]int)
  transitions1a := []int{1}
  transitionsArray[1]['a'] = transitions1a
  transitions1b := []int{2}
  transitionsArray[1]['b'] = transitions1b
  transitions1c := []int{0}
  transitionsArray[1]['c'] = transitions1c
  transitionsArray[2] = make(map[rune][]int)
  transitions2a := []int{0}
  transitionsArray[2]['a'] = transitions2a
  transitions2b := []int{2}
  transitionsArray[2]['b'] = transitions2b
  transitions2c := []int{3}
  transitionsArray[2]['c'] = transitions2c
  transitionsArray[3] = make(map[rune][]int)
  transitions3a := []int{3}
  transitionsArray[3]['a'] = transitions3a
  transitions3b := []int{3}
  transitionsArray[3]['b'] = transitions3b
  transitions3c := []int{3}
  transitionsArray[3]['c'] = transitions3c
  runnable := new(NFA)
  runnable.Q0 = startState
  runnable.FinalStates = finalStatesSlice
  runnable.StateNames = stateNamesSlice
  runnable.Transitions = transitionsArray[0:4]
  return runnable
}
