---
tags:
- javascript
- algorithms
title: The one on Depth First Search (DFS)
description: As you are, so i once was. As i am, so you will be.
date: 2022-11-25T23:00:00Z
draft: false

---
Not that you care but for the 0 number of you that visit this blog, I recently got into doing DSAs again, why? I think it helps with critical thinking and it keeps the complex problem engines turning and I'm toilet at it.

I was attempting to solve Leetcode No 637, Average of Levels in Binary Tree. After getting a brute solution which didn't pass all test cases I gave up and looked into implementing a depth first search.

So i kind of know it now, but I'm going to explain it here so the future dumb ass me that has forgotten it can come back to read it.

### You begin

Depth first search can be used to solve tree problems. It allows all leaves at a level to be hit.

So given the binary tree:

![](/uploads/screenshot-from-2022-11-26-23-36-18.png)

We need to find the average of numbers at each level. Which is the summation of nodes divided by number of nodes at the level.

At level 1 we have `3 /  1` which is `3`.

At level 2, `(2 + 3) / 2` which is `2.5`.

At level 3, `(2 + 4 + 5) / 3` which is `5.5`

So at the end we should return `[3, 2.5, 5.5]`.

The DFS solution to this is:

    const averageOfLevels = function(root) {
        let res = [];
        let queue = [root];
    
        while (queue.length > 0) {
            let arrs = 0;
            let l = queue.length;
    
            for (let i = 0; i < l; i++) {
                let node = queue[0];
                queue.shift();
    
                if (node) {
                    arrs += node.val;
        
                    if (node.left) queue.push(node.left);
                    if (node.right) queue.push(node.right);
                }
            }
            res.push(arrs / l)
        }
    
        return res;
    };

DFS algorithm from what i understand so far require a queue. We can use an array with the `.shift` method to behave like a queue. **The queue at every iteration will hold only nodes at certain level.**

Here comes the explanation of certain lines in the code above:

Line 3: initialize the queue with the root node

Line 5: You'll soon come to realize that on every iteration of the queue we remove the first element, so it's size reduces.

Line 7 and 9: Why not just use the queue.length in the for loop. Well we're removing the first item on every loop as you my notice from line 11. Using the queue.length in line 9 will result in us skipping items.

Hope future me and random you are able to find some understanding from this explanation. If you can't hit me up on twitter, of course if you're future me then may God save you because the past your clearly couldn't.