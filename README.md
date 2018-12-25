# Raspberry Pi 2 - Game 2018 (Assembly - ARM)

This is a game I developed for a **Raspberry Pi 2** in 2018. I used the GPIO ports of the board, to use 6 leds, a buzzer and two buttons.

## GPIO Ports

| Device        | GPIO | Board Pins | I/O    |
|---------------|------|------------|--------|
| LED1 (red)    | 9    | 21         | Output |
| LED2 (red)    | 10   | 19         | Output |
| LED3 (yellow) | 11   | 23         | Output |
| LED4 (yellow) | 17   | 11         | Output |
| LED5 (green)  | 22   | 15         | Output |
| LED6 (green)  | 27   | 13         | Output |
| PUSH BUTTON1  | 2    | 3          | Input  |
| PUSH BUTTON2  | 3    | 5          | Input  |
| SPEAKER       | 4    | 7          | Output |

## The Game

![gameExample.png](readmeResources/gameExample.png?raw=true "Game Example")

This is a two player game. The player 1 controls the button 1 and the player 2 controls the button 2. When running the game, one LED will turn ON randomly* for a time T (T= 1 s. at the beginning). For the time that the led is ON, one of the players has to push his button in time depending on the position of the current lit LED. If the lit LED is one of the three most left leds (RRY), the player 1 has to press the button 1 in time. On the other hand, if the lit LED is one of the three most right leds (YGG), then the player 2 has to press the button 2 in time. If one of the players presses his button out of time, then the game is over. 

After the first round (and if the corresponding player hits), another round starts by turning on a LED randomly* for a time T, where now T is decreased by 50 ms. If the player hits, a new round will start with a decreasing time of 50 ms. The game finishes when one of the players fails or the time T reaches the value 0. 

Once the game is over, the left red led will turn ON if the winner is the player 1, and the right red led will be ON if the second player is the winner. The four most left leds will be used as a score to display the number of rounds in binary. 

You can reset the game, once it has finish running pressing the sequence (Btn1-Btn2-Btn1-Btn2)

## Video

<a href="http://www.youtube.com/watch?feature=player_embedded&v=t0Ilia8EEKc
" target="_blank"><img src="http://img.youtube.com/vi/t0Ilia8EEKc/0.jpg" 
alt="Raspberry Pi 2 - Game" width="240" height="180" border="10" /></a>
