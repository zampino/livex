import {Socket} from "phoenix"

class Channels {
  constructor(upstream) {
    console.log("boot:", upstream);
    this.upstream = upstream
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
        that.upstream.send([idx, prop, value])
      })
    })
    ch.join().receive("ok", msg => {console.log(msg)})
  }

  connect() {
    this.socket.connect()
    this.listenTo(this.socket)
  }

}

export default Channels
