## monitor for replication lag

```sh
SHOW SLAVE STATUS
```

| Field                   | Description                                                   |
| ----------------------- | ------------------------------------------------------------- |
| `Slave_IO_Running`      | Should be `Yes` — checks if replication I/O thread is running |
| `Slave_SQL_Running`     | Should be `Yes` — checks if SQL thread is running             |
| `Last_Error`            | Should be empty — indicates any error encountered             |
| `Seconds_Behind_Master` | Indicates replication lag in seconds                          |
