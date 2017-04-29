//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Christian Franco Soares on 18/04/17.
//  Copyright © 2017 Pandunia. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(Double.pi),
        "√": Operation.UnaryOperation(sqrt),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "-": Operation.BinaryOperation({ $0 - $1 }),
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double )
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperator(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let constant = operations[symbol] {
            switch constant {
            case .Constant(let value): accumulator = value
            case .UnaryOperation(let function): accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
            
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    struct PendingBinaryOperationInfo{
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    var result: Double {
        get{return accumulator}
    }
    
    typealias PropertyList = [AnyObject]
    
    var program: PropertyList {
        get{
            return internalProgram
        }
        set{
            clean()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operand = op as? String {
                        performOperator(symbol: operand)
                    }
                }
            }
            
        }
    }
    
    func clean(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    
}
