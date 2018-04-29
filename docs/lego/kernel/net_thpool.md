# Thread Pool Model for Handling Network Requests

- `Passive`: whenever a network request comes in, callback to thpool.
- `Active`: thpool keep polling if there is new network requests queued.

Previously, our memory side use the Active mode to handle requests, which has very bad latency. Several days ago we changed to the Passive mode, which has a very good latency! One `ib_send_reply` RRT drops from `~20us` to a normal `~6us` for a TensorFlow run.

Never thought this could make such a big difference (~3x slowdown)! Dark network!

--  
Yizhou Shan  
Created: April 29, 2018  
Last Updated: April 29, 2018
