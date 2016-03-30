import {Socket} from "phoenix"

class Channels {
  constructor(ports) {
    console.log("boot:", ports);
    this.stateChangeEvents = ports.stateEvents
    this.penEvents = ports.penEvents
    this.cleanEvents = ports.cleanEvents
    this.socket = new Socket("/socket", {params: {user_id: 1234}})
  }

  listenTo(socket) {
    let that = this
    new Array(1, 2, 3).map(i => {
      that.channel(that.socket, "c" + i)
    })
  }

  channel(socket, idx) {
    let name = "rotor:" + idx
    let ch = socket.channel(name, {})
    let that = this
    new Array("radius", "omega").map(prop => {
      ch.on(prop, data => {
        let [value] = data[prop]
        // console.log(name, prop, value)
        that.stateChangeEvents.send([idx, prop, value])
      })
    })
    ch.join().receive("ok", msg => {console.log(msg)})
  }

  connect() {
    this.socket.connect()
    this.listenTo(this.socket)

    let penChannel = this.socket.channel("rotor:pen", {})
    penChannel.on("toggle", data => {
      let [value] = data.toggle
      this.penEvents.send(value)
    })
    penChannel.join()

    let cleanChannel = this.socket.channel("rotor:clean", {})
    cleanChannel.on("push", data => {
      let [value] = data["push"]
      this.cleanEvents.send(value)
    })
    cleanChannel.join()

  }

}

export default Channels
