# Toutatis Battle System - DEMO
Demo Project for the "Sistemi di Realtà Virtuale" Exam, University of Perugia.
Developers:
- Strippoli Antonio
- Baglioni Michele

<hr>

## TASKS

### 3D Models Low-poly
- [x] Nature Scene
- [x] Main Character
- [x] Sword
- [x] Enemies
  - [x] Dummy

### Optional 3D Models
- [ ] Shield
- [x] Enemies
  - [x] Big enemy (Orc?)

<hr>

### Animations
- [x] Idle (loop)
- [x] Walking (loop)
- [x] Running (loop)
- [x] Attacks
  - [x] LEFT corner to RIGHT corner             (→)
  - [x] TOP_LEFT corner to BOTTOM_RIGHT corner  (↘)
  - [x] TOP corner to BOTTOM corner             (↓)
  - [x] TOP_RIGHT corner to BOTTOM_LEFT corner  (↙)
  - [x] RIGHT corner to LEFT corner             (←)
  - [x] BOTTOM_RIGHT corner to TOP_LEFT corner  (↖)
  - [x] BOTTOM corner to TOP corner             (↑)
  - [x] BOTTOM_LEFT corner to TOP_RIGHT corner  (↗)

### Optional Animations
- [ ] Additional idle
- [ ] Shield parry
- [ ] Heal animation (drinking)

<hr>

### Scripts
- [x] Movement
  - [x] Simple Movement
  - [x] Movement executing animations
- [x] 3D Person Camera follow
- [x] Combat System
  - [x] Swipe System
    - [x] Recognizement of swipes on screen, pressing LEFT Mouse Button (A Swipe is given from the angle of the first and last point on mouse movement path while pressing left button)
    - [x] Character ATTACK animation execution
  - [x] Damage system
  - [x] Enemy System
    - [x] Go towards the Player and attacks if enough near
    - [x] Go to the spawn point if the player runs
    - [x] Can Take damage with swipes attack
    - [x] Critical Point where you can do more damage, key for the combat system
- [x] GUI Menu
  - [x] Health Bar
  - [x] Damages number when hitting

### Optional Scripts
- [ ] Advanced Movement, head movement with camera, then body movement
- [ ] Combat System
  - [ ] Damage Numer Animation (number floating/number on the right/left of the UI)
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
- [x] Health Bar
- [x] Font and color for damage number
- [ ] Title Screen mockup
- [ ] Pause Menu mockup
- [x] Mouse icon