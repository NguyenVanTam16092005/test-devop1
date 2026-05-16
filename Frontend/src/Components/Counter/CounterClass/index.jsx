import React from "react";
import "../App.css";
class CounterClass extends React.Component {
  constructor() {
    super();
    this.increment = this.increment.bind(this);
    this.decrement = this.decrement.bind(this);
    this.reset = this.reset.bind(this);
    this.state = {
      number: 0,
    };
  }

  increment() {
    this.setState({
      number: this.state.number + 1,
    });
  }

  decrement() {
    this.setState({
      number: this.state.number - 1,
    });
  }

  reset() {
    this.setState({
      number: 0,
    });
  }

  render() {
    return (
      <div>
        <h2 className="countClass">Class Base Approach</h2>
        <h2>Counter = {this.state.number}</h2>
        <button onClick={this.increment}>+</button>{" "}
        <button onClick={this.decrement}>-</button>{" "}
        <button onClick={this.reset}>Reset</button>
      </div>
    );
  }
}

export default CounterClass;
