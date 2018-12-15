package main

import (
	"./machine"
	"os"
	"fmt"
	"strconv"
	"container/list"
)


type NFAJob struct {
	TapeIndex int
	CurrState int
}

func worker(in chan NFAJob, out chan []NFAJob, final chan int, tape []rune, m *machine.NFA, die chan bool) {
	var assignedJob NFAJob
	//fmt.Printf("tapeSymbol: %c\n", tape[assignedJob.TapeIndex])
	for {
		select {
			case _ = <- die:
				return
			case assignedJob = <- in:
		}
		
		nextStates, ok := m.Transitions[assignedJob.CurrState][tape[assignedJob.TapeIndex]]
		if ok {
			returnSlice := make([]NFAJob, len(nextStates))
			if assignedJob.TapeIndex + 1 < len(tape) {
				for i, nextState := range nextStates {
					returnSlice[i] = NFAJob{assignedJob.TapeIndex + 1, nextState}
					//fmt.Printf("sending Job back %c %s\n", tape[assignedJob.TapeIndex + 1], m.StateNames[nextState])
				}
				out <- returnSlice
			}	else {
				//tape finished, check if any of the new states are accepting
				for _, stateIndex := range nextStates {
					if m.FinalStates[stateIndex] {
						//one of the new states is accepting, signal success to master
						//fmt.Printf("reached accepting state %s\n", m.StateNames[stateIndex])
						final <- stateIndex
						break
					}
				}
				//kill this branch of execution with the following:
				out <- []NFAJob{}
			}
		} else {
			//no transition for this rune at this state, kill this branch of execution with the following:
			out <- []NFAJob{}
		}
	}
}

func main() {
	args := os.Args[1:]
	m := machine.GetMachine()
	numWorkers, err := strconv.Atoi(args[0])
	_ = err
	tape := []rune(args[1])
	//fmt.Println(m.StateNames)
	//fmt.Println(numWorkers)
	//fmt.Println(tape)
	toWorkers := make(chan NFAJob, numWorkers)
	fromWorkers := make(chan []NFAJob, numWorkers)
	resultChan := make(chan int)
	killChan := make(chan bool)

	
	for i := 0; i < numWorkers; i++ {
		go worker(toWorkers, fromWorkers, resultChan, tape, m, killChan)
	}

	var outChan chan NFAJob
	var inChan chan []NFAJob
	queue := list.New()
	busyWorkers := 0
	accepted := false
	queue.PushBack(NFAJob{0, m.Q0})
	var nextJob NFAJob
	var nextJobElement *list.Element
	//main serve loop
	for {
		if busyWorkers > 0 {
			//canReceive
			//fmt.Println("can Receive")
			inChan = fromWorkers
		} else {
			//fmt.Println("cannot Receive")
			inChan = nil
		}
		if !accepted && (queue.Len() > 0) {
			//canAssign
			//fmt.Println("can Assign")
			outChan = toWorkers

			nextJobElement = queue.Front()
			queue.Remove(nextJobElement)
			nextJob = nextJobElement.Value.(NFAJob)
		} else {
			//fmt.Println("cannot Assign")
			outChan = nil
		}
		if accepted {return}
		select {
			case exitCode := <- resultChan :
				busyWorkers = 0
				accepted = true
				fmt.Println("Accepted")
				fmt.Println(m.StateNames[exitCode])
			case jobsSlice := <- inChan :
				busyWorkers--
				for _, job := range jobsSlice {
					queue.PushBack(job)
				}
			case outChan <- nextJob :
				busyWorkers++
				//fmt.Printf("Sending new Job to worker: %c %s\n", tape[nextJob.TapeIndex], m.StateNames[nextJob.CurrState])
		}
	}
	for i := 0; i < numWorkers; i++ {
		killChan <- true
	}
	close(toWorkers)
	close(fromWorkers)
	close(resultChan)
	if !accepted {
		fmt.Println("string was rejected")
	}

}

