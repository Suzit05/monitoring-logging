const express = require("express")
const os = require("os")
const app = express()
const port = 3000




app.get("/", (req, res) => {
    const userInfo = os.hostname()
    res.send(`<html><body>
    <h1>Hello from ${userInfo}</h1>
</body></html>`)
})

app.get("/health", (req, res) => {
    res.status(200).send('OK')
})

app.listen(port, () => {
    console.log(`server running at ${port}`)
})