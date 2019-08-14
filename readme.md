# Toutatis Battle System - DEMO
Demo Project for the "Sistemi di Realtà Virtuale" Exam, University of Perugia.
Developers:
- Strippoli Antonio
- Baglioni Michele

## TASKS

### 3D Models Low-poly
- [ ] Main Character
- [ ] Sword
- [ ] Enemies
  - [ ] Dummy

### Optional 3D Models
- [ ] Shield
- [ ] Enemies
  - [ ] Big enemy (Orc?)

<hr>

### Animations
- [ ] Idle (loop)
- [ ] Run (loop)
- [ ] Attacks
  - [ ] LEFT corner to RIGHT corner             (→)
  - [ ] TOP_LEFT corner to BOTTOM_RIGHT corner  (↘)
  - [ ] TOP corner to BOTTOM corner             (↓)
  - [ ] TOP_RIGHT corner to BOTTOM_LEFT corner  (↙)
  - [ ] RIGHT corner to LEFT corner             (←)
  - [ ] BOTTOM_RIGHT corner to TOP_LEFT corner  (↖)
  - [ ] BOTTOM corner to TOP corner             (↑)
  - [ ] BOTTOM_LEFT corner to TOP_RIGHT corner  (↗)

### Optional Animations
- [ ] Additional idle
- [ ] Shield parry
- [ ] Heal animation (drinking)

<hr>

### Scripts
- [ ] Movement
  - [x] Simple Movement
  - [ ] Movement executing animations
- [ ] 3D Person Camera follow ( [WOW Camera](https://www.youtube.com/watch?v=7AtD9LX1C6Q) )
  - NOTE: While pressing down left button and swiping, camera won't rotate anymore, it will just slowly follow mouse movement
- [ ] Combat System
  - [ ] Swipe System
    - [ ] Recognizement of swipes on screen, pressing LEFT Mouse Button (A Swipe is given from the angle of the first and last point on mouse movement path while pressing left button)
    - [ ] Character ATTACK animation execution
  - [ ] Damage system
  - [ ] Damage Numer Animation (number floating/number on the right/left of the UI)
  - [ ] Enemy System
    - [ ] Can Take damage with swipes attack
    - [ ] Critical Point where you can do more damage, key for the combat system
- [ ] GUI Menu
  - [ ] Health Bar
  - [ ] Damages number when hitting

### Optional Scripts
- [ ] Advanced Movement, head movement with camera, then body movement
- [ ] Combat System
  - [ ] Swipe System
    - [ ] Character DEFENCE animation execution
    - [ ] Advanced Character ATTACK animation, creating the animation perfectly according to the angle of the swipe
  - [ ] Thrust ATTACKS touching the screen
  - [ ] Skills (Simple execution of pre-made animations)
  - [ ] Heal System
- [ ] GUI Menu
  - [ ] Title screen
  - [ ] Pause menu

<hr>

### Arts and Graphical stuff
- [ ] Health Bar
- [ ] Font and color for damage number
- [ ] Title Screen mockup
- [ ] Pause Menu mockup
- [ ] [Mouse icon](https://docs.godotengine.org/en/3.0/tutorials/inputs/custom_mouse_cursor.html)