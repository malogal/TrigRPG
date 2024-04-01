# TrigRPG

## Abstract

Mathematical concepts are cited by many as one of the most difficult fields to grasp. 
There have been many attempts at implementing an enjoyable way to learn these concepts,
one such method being video games. If properly planned and executed, video games
can provide an engaging environment to introduce new concepts to players as an aid
to or in substitution of traditional methods of studying. 

Utilizing this method of education, we will be developing a 2-demensional, top-down,
educational role-playing game (RPG). Our project, TrigRPG, is a video game that will
focus on various trigonometric topics.

Our vision for TrigRPG is to introduce an educational video game designed with
higher level mathematics in mind. This contrasts with the most popular educational
games on the market, which are designed for younger students. Trigonometry carries
visual attributes that are impossible to integrate into game mechanics. Yet it is
also abstract and sufficiently advanced enough that the market is not saturated with
trigonometry video games. It is a necessary field to lead into higher-level mathematics,
but its complex nature presents both a design challenge and a potential to demonstrate
that higher-level concepts can be taught through video games.

### Game Specifics

#### BitMasks

All collisions have a bitmask layer and mask. The layer is where the collision shape exists,
the mask is what the collision shape looks for. Below is a list of the current bitmasks:

| Name    | Bit | Description |
| -------- | ------- |
| General  | 1    | Collisions between tiles and bodies |
| Pie | 2     | Pie thrown by the player |
| Radian Pie | 3 | Pie thrown by Lord Radian |
| Player Body    | 4    | The player's body shape. If an enemy tracks the player by sight, use this. |
| Player Damage | 5 | Where the player takes damage.  If an enemy strikes the player, use this for damage. |

Example: An enemy needs to see the player and hurt the player. 

* The player's body will have LAYER 4. 
	* The player's body will not need to MASK 4 as the player isn't concerned with recognizing other player 
	bodies. 
* Enemies' sight range will MASK 4, with no LAYER.
	* They only need to notice the player's body.
* Enemies' damage box will MASK 5, and LAYER 5. 
	* They need to notice the player's hurt-box to perform an animation
	* The player needs to know the enemy attack box is in range 
* The player's hurt but should LAYER 5 and MASK 5. 
	* Layer so that enemies can notice it.
	* Mask so that the player can look for collisions that hurt the player and 
	can update the player's health in turn. 
 
