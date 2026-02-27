# BASIC source excerpts (DND1)

Key lines from the original DND1 BASIC for traceability. Source: GitHub Gist bussiere/11137495, Richard Garriott (C) 1977-2014. OS/8 BASIC, BASE 0.

## Arrays

00170 DIM C(7),C$(7),W(100),D(50,50),P(100),I$(100),B(100,6),B$(100)
00190 G=INT(RND(0)*24+2)
00200 H=INT(RND(0)*24+2)
C(0)=HP, C(1-6)=STR..INT, C(7)=GOLD. W=inventory. D=dungeon 0-25. G,H=player position. B=monsters.

## Data

00270 DATA STR,DEX,CON,CHAR,WIS,INT,GOLD
00280-00310 DATA 15 items with prices
01150-01240 DATA 10 monsters: MAN,GOBLIN,TROLL,SKELETON,BALROG,OCHRE JELLY,GREY OOZE,GNOME,KOBOLD,MUMMY with cols 1,dex,hp,initGold,gold
01250-01270 READ B; B(M,4)=B(M,3), B(M,5)=B(M,6), B(M,1)=1

## Intro and roll

00340 DO YOU NEED INSTUCTIONS
00380 OLD OR NEW GAME
00410 DUNGEON #, 00421 CONTINUES 1=YES 2=NO
00440 PLAYERS NME, 00465-00570 roll 7 stats 3d6, M=7 then *15
00590 CLASSIFICATION FIGHTER CLERIC WIZARD, 00625 NONE re-roll
00770 Fighter C(0)=RND*8+1, 00790 Wizard RND*4+1, 00810 Cleric RND*6+1

## Shop

00860 INPUT Y. 00880-00885 Y 0-15. 00890 C(7)-P(Y). 01290 Cleric no 4,8,9,>10. 01350 Wizard no 3,8,>10.

## Read dungeon

01420 FOR M=0 TO 25 N=0 TO 25: D(M,N)=0 or READ. If 0 then RND<.97 else 7, RND<.97 else 8.

## Commands

01550 1=MOVE 2=OPEN DOOR 3=SEARCH 4=SWITCH WEAPON 5=FIGHT 6=LOOK 7=SAVE 8=USE MAGIC 9=BUY MAGIC 0=PASS 11=BUY H.P. 01600 INPUT T, 01605 T=11 01606 T=12 01610 T=1 move etc.

For full scope and component specs see 00-FULL-SCOPE.md and other build-spec files.
