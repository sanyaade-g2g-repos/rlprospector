 
#DEFINE _WINDOWS
'#DEFINE _FMODSOUND 
'#DEFINE _OSX
'#define FBEXT_NO_EXTERNAL_LIBS -1
#macro draw_string(ds_x,ds_y,ds_text,ds_font,ds_col)    
draw string(ds_x,ds_y),ds_text,,ds_font,custom,@ds_col    
#endmacro

#IFDEF _FMODSOUND
#include once "fmod.bi"
#ENDIF
#include once "ext/graphics/font.bi"
'#include "sdl/sdl.bi"
'#include once "allegro.bi"
#include once "file.bi"
#include "cardobj.bi"

#include once "types.bas"
#include once "tiles.bas"
#include once "credits.bas"
#include once "retirement.bas"  
#include once "math.bas" 
#include once "astar.bas"
#include once "logbook2.bas"
#include once "pirates.bas"
#include once "planet.bas" 
#include once "items.bas"
#include once "ProsIO.bas"
#include once "highscore.bas"
#include once "cargotrade.bas"
'#include once "colonies.bas"
#include once "quests.bas"
#include once "spacecom.bas" 
#include once "fileIO.bas"
#include once "exploreplanet.bas"
#include once "texts.bas"
#include once "crew.bas"
#include once "space.bas"
#include once "kbinput.bas"
#include once "globals.bas"
#include once "compcolon.bas"
#include once "poker.bas"


on error goto errormessage  

 
cls
' Load 
print
print "Prospector "&__VERSION__
print
checkfilestructure
loadconfig
loadfonts
if _tiles=0 or _sysmapt=0 then load_tiles
cls
loadkeyset
loadsounds
load_palette()

if not fileexists("register") then
    f=freefile
    open "register" for output as f
    print #f,"0"
    print #f,""
    if menu("Autonaming/Standard/Babylon 5 Shipnames")=2 then
        print #f,"b5shipnames.txt"
    endif
    
    close #f
    cls
    if askyn("This is the first time you start prospector. Do you want to see the keybindings before you start?(Y/N)") then
       keybindings 
    endif
    
endif
    




do
    setglobals
    do
        titlemenu
        key=keyin("1234567")
        if key="1" then
            if count_savegames()>8 then
                key=""
                dprint "Too many Savegames, choose one to overwrite",14
                text=getfilename()
                if text<>"" then
                    if askyn("Are you sure you want to delete "&text &"(y/n)") then
                        kill("savegames/"&text)
                        key="1"
                    endif
                endif     
            endif
        endif
        if key="2" then key=fromsavegame(key)
        if key="3" then highsc()
        if key="4" then manual
        if key="5" then configuration
        if key="6" then keybindings
        
'        if key="8" then 
'            dim i as _items
'            f=freefile
'            open "items.csv" for output as #f
'            for a=0 to 302
'                i=makeitem(a)
'                if i.ldesc<>"" or i.desig<>"" then
'                    print #f,a &";"& i.desig 
'                endif
'            next
'            close #f
'        endif
'            'dodialog(1,dummy,0)
'            for b=1 to 1000
'                make_spacemap
'                clear_gamestate
'            next
'        endif
        if key="9" then
            a=getnumber(0,10000,0)
            put(30,0),gtiles(gt_no(a)),pset
            sleep
        endif
    loop until key="1" or key="2" or key="7" 
    cls
    if key="1" then start_new_game
        
    if key="1" or key="2" and player.dead=0 then
        key=""
        show_stars(1)
        display_ship(1)
        explore_space
    endif
    
    if key="7" then end
    
    if player.dead>0 then death_message()
    
    set__color( 15,0)
    if _restart=0 then 
        loadgame("empty.sav")
        clear_gamestate
    endif
loop until _restart=1
#ifdef _FMODSOUND
fSOUND_close
#endif
end

function player_energylimits() as short
    return 0
end function

function titlemenu() as short
    dim as short bg 
    gfx.font.loadttf("graphics/plasma01.ttf", TITLEFONT, 32, 128, _screeny/5)
    bg=rnd_range(1,_last_title_pic)
    background(bg &".bmp")
    set__color( 228,0)
    draw_string(_screenx/30+4,_screeny/8+12,"PROSPECTOR",TITLEFONT,_tcol)
    set__color( 227,0)
    draw_string(_screenx/30+3,_screeny/8+9,"PROSPECTOR",TITLEFONT,_tcol)
    set__color( 226,0)
    draw_string(_screenx/30+2,_screeny/8+6,"PROSPECTOR",TITLEFONT,_tcol)
    set__color( 225,0)
    draw_string(_screenx/30+1,_screeny/8+3,"PROSPECTOR",TITLEFONT,_tcol)
    set__color( 101,0)
    draw_string(_screenx/30,_screeny/8,"PROSPECTOR",TITLEFONT,_tcol)

    set__color( 15,0)
    draw_string(_screenx-22*_FW2,_screeny-10*_FH2,__VERSION__ ,FONT2,_tcol)
    draw_string(_screenx-22*_FW2,_screeny-9*_FH2,"1) start new game    ",FONT2,_col)
    draw_string(_screenx-22*_FW2,_screeny-8*_FH2,"2) load saved game   ",FONT2,_col)
    draw_string(_screenx-22*_FW2,_screeny-7*_FH2,"3) display highscore ",FONT2,_col)
    draw_string(_screenx-22*_FW2,_screeny-6*_FH2,"4) read documentation",FONT2,_col)
    draw_string(_screenx-22*_FW2,_screeny-5*_FH2,"5) configuration     ",FONT2,_col)
    draw_string(_screenx-22*_FW2,_screeny-4*_FH2,"6) view/change keys  ",FONT2,_col)
    draw_string(_screenx-22*_FW2,_screeny-3*_FH2,"7) exit              ",FONT2,_col)
    
    return 0
end function

function start_new_game() as short
    dim as string text
    dim as short a,b,c,f,d
    dim i as _items
    dim debug as byte
    debug=3
    make_spacemap() 
    if debug=1 then
        f=freefile
        open "planettemp.csv" for output as #f
        for a=0 to laststar
            text=map(a).spec &";"
            for b=1 to 9
                text=text &";"
                if map(a).planets(b)>0 and map(a).planets(b)<1024 then
                    makeplanetmap(map(a).planets(b),b,map(a).spec)
                    text=text &planets(map(a).planets(b)).temp 
                endif
            next
            print #f,text
            print ".";
        next
        close #f
    endif
    background(rnd_range(1,_last_title_pic)&".bmp")
    text="/"&makehullbox(1,"data/ships.csv") &"/"&makehullbox(2,"data/ships.csv") &"/"&makehullbox(3,"data/ships.csv") &"/"&makehullbox(4,"data/ships.csv") &"/"&makehullbox(6,"data/ships.csv")
    if _startrandom=1 then 
        b=menu("Choose ship/Scout/Long Range Fighter/Light Transport/Troop Transport/Pirate Cruiser/Random",text)
    else
        b=rnd_range(1,4)
    endif
    player=makeship(1)
    if b=6 then b=rnd_range(1,4)
    c=b  
    if b=5 then c=6
    upgradehull(c,player)
    d=0
    do
        d+=1
        placeitem(rnd_item(45),0,0,0,0,-1) 'Weapons and armor
    loop until equipment_value>750 or d>5 'No more than 6 w&as
    d=0
    do
        d+=1
        placeitem(rnd_item(44),0,0,0,0,-1) 'Other stuff
    loop until equipment_value>1000 and d>2 'At least 3 other stuffs
    
    if b=1 then
        placeitem(makeitem(100),0,0,0,0,-1)
        placeitem(makeitem(100),0,0,0,0,-1)
        placeitem(makeitem(100),0,0,0,0,-1)
        placeitem(makeitem(123),0,0,0,0,-1)
        placeitem(makeitem(152),0,0,0,0,-1)
        i.ty=52
        i.v1=1
        i.desig="SC"
        placeitem(i,0,0,0,0,-1)
'        placeitem(makeitem(250),0,0,0,0,-1)
'        placeitem(makeitem(162),0,0,0,0,-1)
'        placeitem(makeitem(162),0,0,0,0,-1)
'        placeitem(makeitem(163),0,0,0,0,-1)
        if debugvacuum=1 then placeitem(makeitem(23),0,0,0,0,-1)
        'player.cargo(1).x=10
'        placeitem(makeitem(52),0,0,0,0,-1)
'        placeitem(makeitem(52),0,0,0,0,-1)
'        placeitem(makeitem(52),0,0,0,0,-1)
'        for a=0 to 1000
'        i=makeitem(96)
'        placeitem(i,0,0,0,0,-1)
'        reward(2)+=i.v1
'        next     
        'player.pilot=3
        'placeitem(makeitem(85),0,0,0,0,-1)
        'placeitem(makeitem(85),0,0,0,0,-1)
    endif
    
    addmember(1,0)
    addmember(2,1)
    addmember(3,1)
    addmember(4,1)
    addmember(5,1)
    if debug=3 then player.questflag(22)=1

    if b=2 then 
        placeitem(makeitem(103),0,0,0,0,-1)
        placeitem(makeitem(110),0,0,0,0,-1)
        placeitem(makeitem(110),0,0,0,0,-1)
    endif
    if b=3 then
        player.cargo(1).x=11
        player.cargo(2).x=rnd_range(1,3)
        player.cargo(1).y=nearest_base(player.c)
        player.cargo(2).y=rnd_range(1,5)*player.cargo(2).x
    endif
    if b=4 then
        player.security=5
        for c=6 to 10
            addmember(7,0)
        next
    endif
    if rnd_range(1,100)<51 then
        player.weapons(1)=makeweapon(rnd_range(6,7))
    else
        player.weapons(1)=makeweapon(rnd_range(1,3))
    endif
    if b=5 then
        player.weapons(1)=makeweapon(2)
        player.weapons(2)=makeweapon(99)
        player.weapons(3)=makeweapon(99)
        pirateupgrade
        recalcshipsbays()
        player.engine=2
        player.hull=10
        faction(0).war(2)=-100
        faction(0).war(1)=100
        player.c=map(piratebase(0)).c
        lastfleet=5
        for a=1 to 5
            fleet(a)=makemerchantfleet
            fleet(a).c=basis(rnd_range(0,2)).c
        next
    endif
    if start_teleport=1 then artflag(9)=1
    cls
    set__color( 11,0)
    if b<5 then
        c=textbox("An unexplored sector of the galaxy. You are a private Prospector. You can earn money by mapping planets and finding resources. Your goal is to make sure you can live out your life in comfort in your retirement. || But beware of alien lifeforms and pirates. You start your career with a nice little "&player.h_desig &".",5,5,50,11,0)
        draw_string(5*_fw1,5*_fh1+c*_fh2, "You christen the beauty (Enter to autoname):",font2,_col)
        faction(0).war(1)=0
        faction(0).war(2)=100
        faction(0).war(3)=0
        faction(0).war(4)=100
        faction(0).war(5)=100
    else
        c=5+textbox("A life of danger and adventure awaits you, harassing the local shipping lanes as a pirate. It won't be easy but if you manage to get a lot of money you will be able to spend the rest of your life in luxury. You start your career with a nice little "&player.h_desig &".",5,5,50,11,0)
        draw_string(5*_fw1,5*_fh1+c*_fh2, "You christen the beauty (Enter to autoname):",font2,_col)
        faction(0).war(1)=100
        faction(0).war(2)=0
        faction(0).war(3)=100
        faction(0).war(4)=0
        faction(0).war(5)=100
    endif
    faction(1).war(2)=100
    faction(1).war(4)=100
    faction(2).war(1)=100
    faction(2).war(3)=100
    faction(3).war(2)=100
    faction(3).war(4)=100
    faction(4).war(1)=100
    faction(4).war(3)=100
    
    player.desig=gettext((5*_fw1+44*_fw2)/_fw2,(5*_fh1+c*_fh2)/_fh2,32,"")
    if player.desig="" then player.desig=randomname()
    a=freefile
    if open ("savegames/"&player.desig &".sav" for input as a)=0 then
        close a
        do
            draw_string (50,10*_fh2, "That ship is already registered.",font2,_col)
            draw_string(50,9*_fh2, "You christen the beauty:" &space(25),font2,_col)
            player.desig=gettext((5*_fw1+25*_fw2)/_fw2,(5*_fh1+c*_fh2)/_fh2,13,"")
            if player.desig="" then player.desig=randomname()
        loop until fileexists("savegames/"&player.desig &".sav")=0    
    endif
    if debug=3 or debug=99 then 
        fleet(lastfleet+1)=makealienfleet
        fleet(lastfleet+1).c=basis(0).c
        fleet(lastfleet+2)=makealienfleet
        fleet(lastfleet+2).c=basis(1).c
        fleet(lastfleet+3)=makealienfleet
        fleet(lastfleet+3).c=basis(2).c
        dprint "fleettypes"& fleet(lastfleet+1).ty &":" & fleet(lastfleet+2).ty &":"& fleet(lastfleet+3).ty
        lastfleet+=3
    endif
    if debug=99 then
        upgradehull(18,player,0)
        player.hull=50
        player.engine=6
        player.sensors=6
        player.shield=5
        player.weapons(1)=makeweapon(66)
        player.weapons(2)=makeweapon(66)
        player.weapons(3)=makeweapon(66)
    endif
    if debug=2 then dprint disnbase(map(sysfrommap(specialplanet(7))).c) &":"& disnbase(map(sysfrommap(specialplanet(46))).c)
    just_run=run_until
    return 0
end function

function fromsavegame(key as string) as string
    dim as short c
    c=count_savegames
    cls
    if c=0 then 
        dprint "No Saved Games"
        no_key=keyin
        key=""
    else
        loadgame(getfilename())
        if player.desig="" then key=""
        player.dead=0
        if savefrom(0).map>0 then            
            landing(0)
        endif
'        f=freefile
'        open "specials.txt" for output as #f
'        for c=0 to lastspecial
'            print #f,specialplanet(c)
'        next
'        close #f
    endif
    cls
    return key
end function

function targetlanding(mapslot as short,test as short=0) as short
    dim as _cords p
    dim as string key
    dim as short c,osx
    cls
    screenset 1,1
    
    dprint "Choose landing site"
    p.x=30
    p.y=10
    key=get_planet_cords(p,mapslot)
    if key=key__enter then
        do
            p=movepoint(p,5)
            c+=1
            player.fuel-=1
        loop until c>5 or (tiles(abs(planetmap(p.x,p.y,mapslot))).gives=0 and tiles(abs(planetmap(p.x,p.y,mapslot))).walktru=0 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>3+c+planets(mapslot).grav+planets(mapslot).dens)
        if c<=5 then
            landing(mapslot,p.x,p.y,c)
        else
            dprint "Couldn't land there, landing aborted",14
        endif
    endif
    return 0
end function


function landing(mapslot as short,lx as short=0,ly as short=0,test as short=0) as short
    dim as short l,m,a,b,c,d,dis,alive,dead,roll,target,xx,yy,slot,sys,landingpad,landinggear,who(128),last2,alle
    dim light as single
    dim p as _cords
    dim last as short
    dim awayteam as _monster
    dim nextmap as _cords
    p.x=lx
    p.y=ly
    #ifdef _FMODSOUND
    if (_sound=0 or _sound=2) and mapslot>0 then FSOUND_PlaySound(FSOUND_FREE, sound(11))
    #endif
    for b=0 to laststar
        for c=1 to 9
            if mapslot=map(b).planets(c) then 
                slot=c
                sys=b
            endif
        next
    next
    if savefrom(0).map=0 then
        if mapslot=specialplanet(29) and findbest(89,-1)>0 then mapslot=specialplanet(30)
        if mapslot=specialplanet(30) and findbest(89,-1)=-1 then mapslot=specialplanet(29)
        if mapslot=specialplanet(29) then specialflag(30)=1
        if _warnings=0 and player.hull=1 then
            if not askyn("Pilot: 'Are you sure captain? I can't guarantee i get this bucket up again'(Y/N)",14) then return 0
        endif
        if mapslot>0 then
            cls
            if planetmap(0,0,mapslot)=0 then makeplanetmap(mapslot,slot,map(sys).spec)
            awayteam.hp=0
            for b=1 to 128
                if crew(b).hpmax>0 and crew(b).hp>0 and crew(b).onship=0 and crew(b).disease=0 then 
                    awayteam.hp+=1
                    crew(b).hp=crew(b).hpmax
                endif
            next
            'awayteam.hpmax=awayteam.hp
            if player.dead=0 then
                do
                    if lx=0 and ly=0 then p=rnd_point(mapslot,0)
                loop until tiles(abs(planetmap(p.x,p.y,mapslot))).locked=0 and tiles(abs(planetmap(p.x,p.y,mapslot))).gives=0 and abs(planetmap(p.x,p.y,mapslot))<>45 and abs(planetmap(p.x,p.y,mapslot))<>80 
                'if ((mapslot=pirateplanet(0) or mapslot=pirateplanet(1) or mapslot=pirateplanet(2)) and player.pirate_agr<=0) or isgasgiant(mapslot)<>0 then
                    for x=0 to 60
                        for y=0 to 20
                            if planetmap(x,y,mapslot)=68 and last<128 then
                                last+=1
                                pwa(last).x=x
                                pwa(last).y=y
                            endif
                        next
                    next
                    if last>0 then
                        if askyn("shall we use the landingpad to land?(y/n)") then 
                            p=pwa(rnd_range(1,last))
                            landingpad=5
                        endif
                    endif
                'endif
                player.landed.x=p.x
                player.landed.y=p.y
                player.landed.m=mapslot
                nextmap=player.landed
                equip_awayteam(player,awayteam,mapslot)
            endif
            
            last2=no_spacesuit(who(),alle)
            if last2>0 and ep_needs_Spacesuit(mapslot,awayteam.c)<>0 then
                if alle=0 then
                    if askyn("You will need spacesuits on this planet. Do you want to leave "&last2 &" crewmembers who have none on the ship? (Y/N)") then
                        remove_no_spacesuit(who(),last2)
                    endif
                else
                    if askyn("You need spacesuits on this planet and don't have any. Shall we abort landing? (y/n)") then return 0
                endif
            endif
            
            if awayteam.stuff(8)=1 then dprint "You deploy your satellite"
            roll=rnd_range(1,6)+rnd_range(1,6)+landingpad+player.pilot(0)+addtalent(2,8,1)
            landinggear=findbest(41,-1)
            if landinggear>0 and landingpad=0 then roll=roll+item(landinggear).v1
            target=2*planets(mapslot).dens+2*planets(mapslot).grav^2
            if mapslot<>specialplanet(2) and test=0 then
                dprint "("&roll &":"&target &")"
                if roll>target then
                    if landingpad=0 then
                        dprint ("Your pilot succesfully landed in the difficult terrain",10) 
                    else
                        dprint ("You landed on the landinpad",10)
                    endif
                    player.fuel=player.fuel-1
                    gainxp(2)
                else
                    if landingpad=0 then
                        dprint ("your pilot damaged the ship trying to land in difficult terrain.",12)
                    else 
                        dprint ("your pilot actually manged to damage the ship while landing on a landing pad!",12)
                    endif
                    player.hull=player.hull-1
                    player.fuel=player.fuel-2-int(planets(mapslot).grav)
                    if player.hull<=0 then
                        dprint ("A Crash landing. you will never be able to start with that thing again",12)
                        if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>10 then
                            dprint ("but your pilot wants to try anyway and succeeds!",12)
                            player.hull=1
                        else
                            player.dead=4
                        endif
                        no_key=keyin
                    endif
                endif
            endif
        endif
        if isgardenworld(nextmap.m) then changemoral(3,0)
        awayteam.oxygen=awayteam.oxymax
        awayteam.jpfuel=awayteam.jpfuelmax
        
        else
            awayteam=savefrom(0).awayteam
            nextmap=savefrom(0).ship
            nextmap.m=savefrom(0).map
        endif
        
        if player.dead=0 and awayteam.hp>0 then
            do
                equip_awayteam(player,awayteam,slot)
                nextmap=explore_planet(awayteam,nextmap,slot)
                cls
                removeequip
                
                for b=6 to 128
                    if crew(b).hp<=0 then
                        crew(b)=crew(0)
                    else
                        c+=1
                    endif
                next
                if c>127 then c=127
                
                for b=6 to c-1
                    if crew(b).hpmax=0 then 
                        swap crew(b),crew(b+1)
                    endif
                next
            
            loop until nextmap.m=-1 or player.dead<>0
            for c=0 to 127
                for b=6 to 127
                    if crew(b).hp<=0 then swap crew(b),crew(b+1)
                next
                
            next
            for b=0 to 127
                if crew(b).onship=4 then
                    crew(b).onship=crew(b).oldonship
                endif
            next
            removeequip
            'artifacts?
            if reward(5)>0 then
                if reward(5)=1 then 
                    player.fuelmax=200
                endif
                if reward(5)=2 then
                    player.stuff(1)=3
                endif
                if reward(5)=3 then
                    slot=getrandomsystem()
                    if slot<0 then slot=rnd_range(0,laststar)
                    map(slot).discovered=1
                    for b=1 to 9
                        if map(slot).planets(b)>0 then
                        if planetmap(0,0,map(slot).planets(b))=0 then makeplanetmap(map(slot).planets(b),b,map(sys).spec)
                        reward(0)=reward(0)+1200
                        reward(7)=reward(7)+600
                        for xx=0 to 60
                            for yy=0 to 20
                                if planetmap(xx,yy,map(slot).planets(b))<0 then planetmap(xx,yy,map(slot).planets(b))=planetmap(xx,yy,map(slot).planets(b))*-1
                            next
                        next
                        endif
                    next
                    dprint "the data from the computer describes a system with the coordinates "& map(slot).c.x &":" & map(slot).c.y
                endif
                if reward(5)=4 then 
                    player.stuff(2)=3
                endif
                if reward(5)=5 then
                    player.stuff(0)=3
                endif
                reward(5)=0
                
            endif
        endif
        c=6
        dis=0
        if crew(1).hp<=0 and player.dead=0 then 
            crew(1).hp=crew(1).hpmax
            b=rnd_range(1,3)
            if b=1 then dprint "Captain "&crew(1).n &" was just unconcious.",10
            if b=2 then dprint "Captain "&crew(1).n &" got better.",10
            if b=3 then dprint "Captain "&crew(1).n &" miracoulously recovered.",10
        endif
        for b=1 to 128
            if crew(b).hp<crew(b).hpmax and crew(b).hp>0 and crew(b).disease=0 then crew(b).hp=crew(b).hpmax
        next
        for b=6 to 128
            if crew(b).hp<=0 then
                crew(b)=crew(0)
            else
                if crew(b).disease>dis then dis=crew(b).disease
                c+=1
            endif
        next
        awayteam.disease=dis
        d=0
        do
            d+=1
            a=0
            for b=6 to c-1
                if crew(b).hpmax=0 and crew(b+1).hpmax>0 then 
                    swap crew(b),crew(b+1)
                    a=1
                endif
            next
        loop until a=0 or d>=1000
        for b=0 to lastitem
            if item(b).w.s<0 then 
                item(b).w.s=-1
                item(b).w.m=0
                item(b).w.p=0
            endif
        next
        player.landed.m=0
        show_stars(1)
        display_ship
        if awayteam.stuff(8)=1 and player.dead=0 and test=0 then 
            if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)+player.tractor>6 then
                dprint "You rendevouz with your satellite and take it back in",10
            else
                dprint "When trying to rendevouz with your satellite your pilot rams and destroys it.",12
                item(findbest(10,-1))=item(lastitem)
                lastitem=lastitem-1
                no_key=keyin
            endif
        else
            dprint ""
        endif
    return 0
end function

function scanning() as short
    dim mapslot as short
    dim as short slot
    dim sys as short
    dim scanned as short
    dim itemfound as short
    dim a as short
    dim b as short
    dim x as short
    dim y as short
    dim key as string
    dim as short osx
    dim as single roll,target
    dim debug as byte
    dim as short plife
    debug=1
    'if getsystem(player)>0 then
    a=getplanet(getsystem(player))
    slot=a
    if a>0 then 
        sys=getsystem(player)
        mapslot=map(sys).planets(a)
        if mapslot=specialplanet(29) and findbest(89,-1)>0 then mapslot=specialplanet(30)
        if mapslot=specialplanet(30) and findbest(89,-1)=-1 then mapslot=specialplanet(29)
        if mapslot=specialplanet(29) then specialflag(30)=1
        if mapslot<0 and mapslot>-20000 then map(sys).planets(a)=asteroidmining(mapslot)
        if mapslot=-20001 then dprint "A helium-hydrogen gas giant"
        if mapslot=-20002 then dprint "A methane-ammonia gas giant"
        if mapslot=-20003 then dprint "A hot jupiter"
        if mapslot<-20000 or isgasgiant(mapslot)>0 then gasgiantfueling(mapslot,a,sys)
        if mapslot>0 and isgasgiant(mapslot)=0 then
        if planetmap(0,0,mapslot)=0 then
            makeplanetmap(mapslot,a,map(sys).spec)
            'makefinalmap(mapslot)
        endif
        if planets(mapslot).mapstat=0 then planets(mapslot).mapstat=1 
        for x=60 to 0 step -1
            for y=0 to 20
                target=10+(planets(mapslot).mapped/100*player.sensors)+planets(mapslot).dens 
                if abs(planetmap(x,y,mapslot))=8 then target=target-1 
                if abs(planetmap(x,y,mapslot))=7 then target=target-2 
                roll=rnd_range(1,6)+rnd_range(1,6)+minimum(player.science(0)+1,player.sensors)
                if  roll>target and planetmap(x,y,mapslot)<0 then
                    planetmap(x,y,mapslot)=planetmap(x,y,mapslot)*-1
                    reward(0)=reward(0)+.5
                    reward(7)=reward(7)+planets(mapslot).mapmod
                    scanned=scanned+1
                endif
            next
        next
        for b=0 to lastitem
            if item(b).w.m=mapslot and item(b).w.p=0 and item(b).w.s=0 then
                target=(7+planets(mapslot).dens)*item(a).scanmod 
                roll=(rnd_range(1,6)+rnd_range(1,6)+addtalent(4,15,1)+minimum(player.science(0),player.sensors))*item(b).scanmod
                if roll>target then 
                    item(b).discovered=1
                    itemfound+=1
                endif
            endif
        next
        planets(mapslot).mapped=planets(mapslot).mapped+scanned
        if scanned>50 then gainxp(4)
        cls
        if mapslot=player.questflag(7) then dprint "This is the planet Eridiani Explorations wants us to map completely"
        if mapslot=pirateplanet(0) then
            dprint "Science Officer: 'I am picking up signs of civilisation on this planet'",15
        endif
        for a=0 to lastspecial
            if mapslot=specialplanet(a) then 
                if specialflag(a)<=1 then 
                    if specialplanettext(a,specialflag(a))<>"" then
                        dprint specialplanettext(a,specialflag(a)) &" Key to continue",15
                        no_key=keyin
                    endif
                endif
            endif
        next
        dprint "Scanned "&scanned &" km2"
        if itemfound>0 then
            dprint "Detected "&itemfound &" objects."
        else
            dprint "Detected no objects."
        endif
        if planets(mapslot).flags(22)=1 then dprint "A mining station on this planet sends a distress signal. They need medical help.",15
        if planets(mapslot).flags(22)=2 then dprint "There is a mining station on this planet. They send greetings.",15
        if planets(mapslot).flags(23)>0 then dprint "Science Officer: 'I can detect several ships on this planet.",15
        if planets(mapslot).flags(24)>0 then dprint "Science Officer: 'This planet is completely covered in rain forest. What on first glance appears to be its surface is actually the top layer of a root system.",15
        if planets(mapslot).flags(25)>0 then dprint "Science Officer: 'The biosphere readings for this planet are off the charts. We sure will find some interesting plants here!",15
        if planets(mapslot).flags(26)>0 then dprint "Science Officer: A very deep ocean covers this planet. Sensor readings seem to indicate large cave structures at the bottom.",15
        if planets(mapslot).flags(27)>0 then 
            dprint "Science Officer: 'This is a sight you get to see once in a lifetime. The orbit of this planet is unstable and it is about to plunge into its sun! Gravity is ripping open its surface, solar wind blasts its material into space. In a few hours it will be gone.'",15
            planets(mapslot).flags(27)=2
        endif
        if isgardenworld(mapslot) then dprint "This planet is earthlike."
        if planets(mapslot).colflag(0)>0 then dprint "There is a "& companyname(planets(mapslot).colflag(0)) &" colony on this planet. They are sending greetings."
        if debug=1 then dprint "Map number "&slot &":"& mapslot
        osx=30-_mwx/2
        
        for a=0 to planets(mapslot).life
            if rnd_range(1,6)+rnd_range(1,6)+player.science(1)>7 then plife=plife+((planets(mapslot).life+1)*3)/100
        next
        if plife>1 then plife=1
        if plife>planets(mapslot).highestlife then 
            planets(mapslot).highestlife=plife 
            dprint "Revising earlier lifeform estimate",c_yel
        endif
        do
            display_planetmap(mapslot,osx,1)
            dplanet(planets(mapslot),slot,scanned)
            dprint ""
            no_key=keyin(key_la & key_tala &" abcdefghijklmnopqrstuvwxyz" &key_east &key_west)
            if no_key=key_east then osx+=1
            if no_key=key_west then osx-=1
            if osx<0 then osx=0
            if osx>60-_mwx then osx=60-_mwx
        cls
        
        loop until no_key<>key_east and no_key<>key_west
        if no_key=key_la then key=key_la
        if no_key=key_tala then key=key_tala
        if rnd_range(player.pilot(0),6)+rnd_range(1,6)+player.pilot(0)<8 and player.fuel>30 then
            dprint "your pilot had to correct the orbit.",14
            x=rnd_range(1,4)-player.pilot(0)
            if x<1 then x=1
            player.fuel=player.fuel-x
            
        endif
        endif
        if key=key_la then landing(map(sys).planets(slot))
        if key=key_tala then targetlanding(map(sys).planets(slot))
    endif
    'show_stars(1,0)
    'displayship
    return 0
end function

function asteroidmining(slot as short) as short
    dim it as _items
    dim en as _fleet
    dim as short f,q,m,roll
    dim mon(6) as string
    mon(1)="a huge crystaline lifeform, vaguely resembling a spider. It jumps from asteroid to asteroid, it's diet obviously being metal ores. Looks like it has just put our ship on the menu! It is  coming this  way!"
    mon(2)="a huge lifeform made entirely of metal! It is spherical and drifts among the astroids. There are no detectable means of locomotion, except for 3 openenings at the equator. It is radiating high amounts of heat, especially at those openings. Looks like it is a living, moving fission reactor!"
    mon(3)="a dense cloud of living creatures, from microscopic to about 10cm long. They seem to be living insome kind of symbiosis, with different specimen performing different tasks."
    mon(4)="a giant wormlike creature. It's biochemistry is based on liquid hydrogen. The heat of our engines is attracting it."
    mon(5)="an enormous blob of living plasma!"
    mon(6)="a gigantic creature resembling a jellyfish!"
    en.ty=2
    m=rnd_range(1,6)
    if show_all then dprint ""&slot
    roll=rnd_range(1,100)
    slot=slot-rnd_range(1,10)
    player.fuel=player.fuel-1
    if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)<9 then player.fuel=player.fuel-rnd_range(1,3)
    if (slot<-11 and slot>-13) or (slot<-51 and slot>-54)  then
        dprint "you have discovered a dwarf planet among the asteroids!",10
        no_key=keyin
        lastplanet=lastplanet+1
        slot=lastplanet
    else
        f=rnd_range(1,6)+rnd_range(1,6)+player.tractor*2+minimum(player.science(0)+1,player.sensors+1)+3*addtalent(2,9,2)
        if f+slot>5 then
            do
                it=makeitem(96,f+slot+165,-2)
            loop until it.ty=15
            it.v5=it.v5+100
            if askyn("Science officer: 'There is an asteroid containing a high ammount of "&it.desig &". shall we try to take it aboard?'(y/n)") then 
                display_ship()                            
                q=-1
                do                                        
                    if _warnings=0 and player.hull=1 then 
                        q=askyn("Pilot: 'If i make a mistake it could be fatal. Shall I really try?'(y/n)")
                    endif
                    if q=-1 then
                        if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)+player.tractor*2>6+rnd_range(1,6) then
                            q=0
                            placeitem((it),0,0,0,0,-1)
                            reward(2)=reward(2)+it.v5
                            dprint "We got it!",10
                        else
                            player.hull=player.hull-1
                            display_ship()
                            dprint "Your pilot hit the asteroid, damaging the ship, and changing the asteroids trajectory.",14
                            if player.hull>0 then
                                q=askyn("try again? (y/n)")
                                if q=-1 then 
                                    dprint "Pilot: 'starting another attempt.'"
                                    sleep 300
                                endif
                            else
                                q=0
                                player.dead=19
                                exit function
                            endif
                        endif
                    endif
                    player.fuel=player.fuel-rnd_range(1,3)
                    roll=roll-1
                    if roll<7 then q=0
                    if player.fuel<10 then player.fuel=10
                loop until q=0
            else
                slot=slot+rnd_range(1,2)
                if slot>=0 then slot =-1
            endif
        else
            dprint "Nothing remarkable."
        endif
    endif
    if roll<4 then
        if rnd_range(1,100)<85 then
            dprint "A ship has been hiding among the asteroids.",14
            if faction(0).war(1)<0 then
                dprint "It hails us.",10
            else
                dprint "It attacks!",12
                no_key=keyin
                if rnd_range(1,6)<5 then
                    en.ty=1
                    en.mem(1)=makeship(3)
                else
                    en.ty=1
                    en.mem(1)=makeship(4)
                endif
                no_key=keyin
                spacecombat(en,10)
                if player.dead<0 then player.dead=0
            endif
        else
            dprint "A ship has been hiding among the asteroids.",14
            no_key=keyin
            dprint "Wait. that is no ship. It is  "&mon(m) &"!",14
            no_key=keyin
            en.ty=8
            en.mem(1)=makeship(20+m)
            spacecombat(en,20)
            
            if player.dead>0 then 
                player.dead=20
            else
                if player.dead=0 then
                    dprint "We got very interesting sensor data from that being.",10
                    reward(1)=reward(1)+rnd_range(10,180)*rnd_range(1,maximum(player.science(0),player.sensors))
                    player.alienkills=player.alienkills+1
                else
                    player.dead=0
                endif
            endif
        endif
        cls
        display_ship()
        show_stars(1)
    endif
    return slot
end function

function gasgiantfueling(p as short, orbit as short, sys as short) as short
    dim as short fuel,roll,noa,a,mo,m,probe,probeflag,hydrogenscoop,debug,freebay
    dim en as _fleet
    static restfuel as byte
    dim as string mon(6)
    mon(1)="a giant wormlike creature. It's biochemistry is based on liquid hydrogen. The heat of our engines is attracting it."
    mon(2)="an enormous blob of living plasma!"
    mon(3)="a gigantic creature resembling a jellyfish!"
    mon(4)="a flock of large tube shaped creatures with wide maws and sharp teeth!"
    mon(5)="a huge balloon floating in the wind with five, thin, several kilometers long tentacles!"
    mon(6)="a circular flat being floating among the clouds. Three bulges on the top are glowing with static electricity." 
    if p=-20003 then mo=2
    m=isgasgiant(p)
    if isgasgiant(p)>1 then
        if planetmap(0,0,m)<>0 then make_special_planet(m)
        if askyn("As you dive into the upper atmosphere of the gas giant your sensor pick up a huge metal structure. It is a platform, big enough to land half a fleet on it, connected to struts that extend out into the atmosphere. Do you want to try to land on it? (y/n)") then
            landing(map(sys).planets(orbit))
            return 0
        else
            p=-20001
            
        endif
    endif
    hydrogenscoop=1
    for a=1 to player.h_maxweaponslot
        if player.weapons(a).made=85 then hydrogenscoop+=1
        if player.weapons(a).made=86 then hydrogenscoop+=2
    next
    if askyn("Do you want to refuel in the gas giants atmosphere?(y/n)") then
        probe=findbest(56,-1)
        if probe>0 then
            if not(askyn("Do you want to use your gas mining probe?(y/n)")) then probe=0
        endif
        if probe<=0 then
            if _warnings=0 and player.hull=1 then
                if not(askyn("Pilot: 'If i make a mistake we are doomed. Do you really want to try it? (Y/N)")) then return 0
            endif
            if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)+addtalent(2,9,1)<=8+mo then
                dprint "Your Pilot damaged the ship diving into the dense atmosphere",12
                player.hull=player.hull-rnd_range(1,2)
                if p=-20003 then player.hull=player.hull-1
                display_ship
            endif
            if player.hull>0 then
                if debug=1 then dprint ""& hydrogenscoop
                fuel=10+rnd_range(2,7)*hydrogenscoop+addtalent(2,9,3)
                hydrogenscoop-=1
                if hydrogenscoop<=0 then hydrogenscoop=1
                if p=-20001 then fuel=fuel+rnd_range(3,11)*hydrogenscoop
                hydrogenscoop-=1
                if hydrogenscoop<=0 then hydrogenscoop=0
                if p=-20003 then fuel=fuel+rnd_range(5,15)*hydrogenscoop
                
                display_ship
            else
                player.dead=22
            endif
            if map(sys).spec=10 then rg_icechunk()
        
            if rnd_range(1,100)<38-orbit*2 and player.dead=0 then
                roll=rnd_range(1,6)
                dprint "While taking up fuel your ship gets attacked by "&mon(roll),14
                no_key=keyin
                noa=1
                if roll=4 then noa=rnd_range(1,6)+rnd_range(1,6)
                if roll=5 then noa=rnd_range(1,3)
                if roll=6 then noa=rnd_range(1,2)
                for a=1 to noa
                    en.ty=9
                    en.mem(a)=makeship(23+roll)
                next
                spacecombat(en,21)
            
                if player.dead>0 then 
                    player.dead=23
                else
                    if player.dead=0 then
                        dprint "We got very interesting sensor data during this encounter.",10
                        reward(1)=reward(1)+(roll*3+rnd_range(10,80))*rnd_range(1,maximum(player.science(0),player.sensors))
                        player.alienkills=player.alienkills+1
                    else
                        player.dead=0
                    endif
                endif
            endif
        else
            'using probe
            if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)+addtalent(2,9,1)-3+item(probe).v2<=8+mo then probeflag=1
            if rnd_range(1,100)<38-orbit*2 then probeflag=1
            if probeflag=1 then 
                dprint "We lost contact with the probe."
                destroyitem(probe)
            else
                fuel=10+rnd_range(3,9)+addtalent(2,9,3)
                if p=-20001 then fuel=fuel+rnd_range(3,9)
                if p=-20003 then fuel=fuel+rnd_range(5,15)
                if fuel>item(probe).v1 then fuel=item(probe).v1
                'if player.fuel>player.fuelmax+player.fuelpod then player.fuel=player.fuelmax+player.fuelpod                    
            endif
        endif
               
    endif
    if fuel>0 then
        dprint "you take up "&fuel & " tons of fuel.",10
        player.fuel=player.fuel+fuel
        freebay=getnextfreebay
        if player.fuel>player.fuelmax+player.fuelpod and freebay>0 then
            if askyn("Do you want to store the excess fuel in a cargobay?(y/n)") then
                do 
                    player.cargo(freebay).x=10
                    player.cargo(freebay).y=1
                    player.fuel-=30
                    freebay=getnextfreebay
                loop until player.fuel<=player.fuelmax+player.fuelpod or freebay=-1
            endif
        endif
        if player.fuel>player.fuelmax+player.fuelpod then player.fuel=player.fuelmax+player.fuelpod
    endif
    

    return 0
end function

function rg_icechunk() as short
    dim as short debug,x,y,b
    dim gc as _cords
    if rnd_range(1,100)>5+player.sensors then return 0
    dprint "Your sensors seem to pick up something"
    if rnd_range(1,100)>5+player.sensors then 
        dprint "But it is gone again quickly."
        return 0
    endif
    lastplanet+=1
    makemossworld(lastplanet,4)
    for x=0 to 60
        for y=0 to 20
            if abs(planetmap(x,y,lastplanet))=1 then planetmap(x,y,lastplanet)=-4 
            if abs(planetmap(x,y,lastplanet))=2 then planetmap(x,y,lastplanet)=-158 
            if abs(planetmap(x,y,lastplanet))=102 then planetmap(x,y,lastplanet)=-4 
            if abs(planetmap(x,y,lastplanet))=103 then planetmap(x,y,lastplanet)=-7 
            if abs(planetmap(x,y,lastplanet))=104 then planetmap(x,y,lastplanet)=-193 
            if abs(planetmap(x,y,lastplanet))=105 then planetmap(x,y,lastplanet)=-145 
            if abs(planetmap(x,y,lastplanet))=106 then planetmap(x,y,lastplanet)=-145 
            if abs(planetmap(x,y,lastplanet))=146 then planetmap(x,y,lastplanet)=-145 
            if rnd_range(1,6)+player.science(0)>9 then planetmap(x,y,lastplanet)=abs(planetmap(x,y,lastplanet))
        next
    next
    planets(lastplanet).grav=.3
    planets(lastplanet).temp=-120
    planets(lastplanet).atmos=1
    planets(lastplanet).death=5+rnd_range(3,6)
    planets(lastplanet).flags(27)=2
    planets(lastplanet).flags(29)=1 'Planet Flag for Ice Chunk
    if rnd_range(1,100)<10 then
        planets(lastplanet).mon_template(0)=makemonster(rnd_range(62,64),0,0)
        planets(lastplanet).mon_noamin(0)=1
        planets(lastplanet).mon_noamax(0)=3
        
    endif
    for b=0 to 10+rnd_range(0,6)+disnbase(player.c)\4
        gc=rnd_point(lastplanet,1)
        placeitem(makeitem(96,planets(lastplanet).depth+disnbase(player.c)\5,planets(lastplanet).depth+disnbase(player.c)\6),gc.x,gc.y,lastplanet)
    next b
    display_planetmap(lastplanet,30,1)
    dprint "Your sensors pick up a huge chunk of ice in the atmosphere, quickly tumbling down into the denser areas of the gas giant. It is big enough to land on."
    if askyn("Do you want to try to land on it?(y/n)") then
        landing(lastplanet)
        lastplanet-=1
    else
        dprint "You climb back up into free space while the icechunk disintegrates"
    endif
    return 0
end function


function driftingship(a as short)  as short
    dim as short m,b,c,x,y
    dim p(1024) as _cords
    dim land as _cords
    dim as short test=0
    m=drifting(a).m
    if a<=3 and rnd_range(1,100)<10+test and player.turn>5 then
        station_event(m)
    endif
    for x=0 to 60
        for y=0 to 20
            if abs(planetmap(x,y,m))=203 then 
                b+=1
                p(b).x=x
                p(b).y=y
            endif
        next
    next
    c=rnd_range(1,b)
    land.x=p(c).x
    land.y=p(c).y
    land.m=m
    landing(m,p(c).x,p(c).y,1)
    return 0
end function

function moverover(pl as short,ship as _cords,li()as short,lastlocalitem as short)  as short
    dim as integer a,b,c,i,t,ti,x,y
    dim as integer carn,herb,mins,oxy,food,energy,curr,last
    dim as single minebase
    dim as _cords p1,p2,route(1200)
    dim as _cords pp(9)
    t=(player.turn-planets(pl).visited)*10
    for a=0 to lastitem
        if item(a).ty=18 and item(a).w.p=0 and item(a).w.s=0 and item(a).w.m=pl then i=a
    next
    if i>0 and t>0 then
        p1.x=item(i).w.x
        p1.y=item(i).w.y
        for a=0 to t*item(i).v4
            curr+=1
            if curr>last then
                last=ep_autoexploreroute(route(),p1,item(i).v2,pl,ship,li(),lastlocalitem)
                curr=1
            else
                if last>0 then
                    item(i).w.x=route(curr).x
                    item(i).w.y=route(curr).y
                endif
            endif
            ep_roverreveal(i)
        next
        if rnd_range(1,150)<planets(pl).atmos*2 then item(i).discovered=0
        if rnd_range(1,150)<planets(pl).atmos+2 then 
            item(i)=makeitem(65)
        else
            dprint "Receiving the homing signal of a rover on this planet",10
        endif
    endif
    i=0
    for a=0 to lastitem
        if item(a).ty=27 and item(a).w.p=0 and item(a).w.s=0 and item(a).w.m=pl then i=a
        if item(a).ty=15 and item(a).w.p=0 and item(a).w.s=0 and item(a).w.m=pl then 
            minebase+=1.1
            if rnd_range(1,100)<10 then destroyitem(a)
        endif
    next
    if i>0 and t>0 then
        p1.x=item(i).w.x
        p1.y=item(i).w.y
        for x=0 to 60
            for y=0 to 20
                p2.x=x
                p2.y=y
                if abs(planetmap(x,y,pl))=13 then minebase=minebase+2/distance(p1,p2)
                if abs(planetmap(x,y,pl))=7 or abs(planetmap(x,y,pl))=8 then minebase=minebase+1/distance(p1,p2)
            next
        next
        minebase=minebase+planets(pl).minerals
        minebase=minebase+planets(pl).atmos
        minebase=minebase+planets(pl).grav
        minebase=minebase+planets(pl).depth
        minebase=minebase+abs(spacemap(map(sysfrommap(pl)).c.x,map(sysfrommap(pl)).c.y))
        item(i).v1=item(i).v1+0.01*minebase*t*item(i).v3
        if item(i).v1>item(i).v2 then item(i).v1=item(i).v2
        if rnd_range(1,150)<planets(pl).atmos+2 then item(i)=makeitem(66)
    endif
    return 0
end function

function rescue() as short
    dim as short a,c,dis,beacon,cargo
    dim as single b,d
    d=256
    if getinvbytype(9)>0 then
        if askyn("You ran out of fuel. Do you want to use the fuel from the cargo bay?(y/n)",,1) then
            removeinvbytype(9,1)
            player.fuel+=30
            return 0
        endif
    endif
    for a=0 to 2
        b=distance(player.c,basis(a).c)
        if b<d then 
            d=b
            c=a
        endif
    next
    beacon=findbest(36,-1)
    if beacon>0 then 
        dis=item(beacon).v1
        if rnd_range(1,100)<66 then destroyitem(beacon)
    else
        dis=0
    endif
    if d>0 and d<256 then
        dprint "Fuel tanks empty, sending distress signal!",14
        locate 1,1
        no_key=keyin
        if d<5+dis*2 then 
            if faction(0).war(1)<100 then
                dprint "Station " &c+1 &" answered and sent a retrieval team. You are charged "& int(d*(100-dis*10)) & " Cr.",10
                player.money=player.money-int(d*(100-dis*10))
                player.fuel=10
                player.c.x=basis(c).c.x
                player.c.y=basis(c).c.y
            else
                dprint "One of the stations answers, explaining that they will not help a known pirate like you.",12
                player.dead=1
            endif
        else
            dprint "You are too far out in space....",12
            if rnd_range(1,100)<5+dis*2 then
                dprint "Your distress signal is answered!",10
                b=rnd_range(1,33)+rnd_range(1,33)+rnd_range(1,33)
                dprint "A "&shiptypes(rnd_Range(0,16)) &" offers to sell you fuel to get to the nearest station for "& b &" credits per ton. ("& int(disnbase(player.c)*b) &" credits for " &int(disnbase(player.c)) &" tons)."
                if askyn("Do you accept the offer?(y/n)") then
                    if player.money>=int(disnbase(player.c)*b) then
                        player.money=player.money-disnbase(player.c)*b
                    else
                        dprint "You convince them to lower their price. They only take all your money.",10
                        player.money=0
                    endif
                    player.fuel=disnbase(player.c)+2
                    locate 1,1
                    no_key=keyin
                else
                    if not(askyn("Are you certain? (y/n)")) then
                        if player.money>=int(disnbase(player.c)*b) then
                            player.money=player.money-disnbase(player.c)*b
                        else
                            dprint "You convince them to lower their price. They only take all your money.",10
                            player.money=0
                        endif
                        player.fuel=disnbase(player.c)+2
                        locate 1,1
                        no_key=keyin
                    else
                        dprint "they leave again."
                        locate 1,1
                        no_key=keyin
                        player.dead=1
                    endif
                endif
            else
                player.dead=1
            endif
        endif
        locate 1,1
        no_key=keyin
    endif
    return 0
end function



function spacestation(st as short) as _ship
    dim as short a,b,c,d,e,wchance
    static as short hiringpool,questroll,last
    static inv(lstcomit) as _items
    dim quarantine as short
    dim i as _items
    dim key as string
    dim text as string
    dim mtext as string
    dim dum as _station
    cls
    comstr=""
    display_ship
    if player.turn>0 then
        if rnd_range(1,100)<33+faction(0).war(1)+foundsomething and basis(st).company<>3 then
            dprint "The station commander decides to do a routine check on your cargo hold before allowing you to disembark.",14
            no_key=keyin
            d=0
            for b=1 to 10
                c=0
                if player.cargo(b).x=9 and basis(st).company<>1 then c=1 'Embargo
                if player.cargo(b).x=8 and basis(st).company<>2 then c=1 'Embargo
                if player.cargo(b).x=7 and basis(st).company<>4 then c=1 'embargo
                if player.cargo(b).x>1 and player.cargo(b).x<=9 and player.cargo(b).y=0 then c=1 'Stolen
                if c=1 and rnd_range(1,100)>30+player.shieldedcargo-player.cargo(b).x then
                    d=1
                    if player.cargo(b).y>0 then
                        dprint "You are informed that there is an import embargo on "& lcase(basis(st).inv(player.cargo(b).x-1).n) &" and that the cargo will be confiscated.",12
                    else
                        dprint "Your cargo of "& basis(st).inv(player.cargo(b).x-1).n &" gets confiscated because it lacks proper documentation.",12
                    endif
                    player.cargo(b).x=1
                    player.cargo(b).y=0
                    faction(0).war(1)+=1
                endif
            next
            if d=0 then 
                dprint "Everything seems to be ok.",10
                foundsomething-=1
            else
                foundsomething+=5
            endif
        endif
        checkpassenger(st)
        dprint "Morale change:"&(wage-9-bunk_multi*2)&":"& bunk_multi &":"&(player.h_maxcrew+player.crewpod)*1+player.cryo
        for b=2 to 128
            if Crew(b).paymod>0 and crew(b).hpmax>0 and crew(b).hp>0 then
                a=a+Wage*Crew(b).paymod
                crew(b).morale=crew(b).morale+(Wage-9-bunk_multi*2)+addtalent(1,4,5)
                
            endif
        next
        dprint "You pay your crew "&a &" Cr. in wages"        
        player.money=player.money-a
        player=levelup(player,0)
        if shop_order(st)<>0 and rnd_range(1,100)<33 then
            dprint  "Your ordered "&makeitem(shop_order(st)).desig &" has arrived.",12
            b=rnd_range(1,20)
            shopitem(b,st)=makeitem(shop_order(st))
            shopitem(b,st).price=shopitem(b,st).price*2
            shop_order(st)=0
        endif
    endif
    
    ss_sighting(st)
    if basis(st).spy=1 or basis(st).spy=2 then
        if askyn("Do you pay 100 cr. for your informant? (y/n)") then
            player.money=player.money-100
            if player.money<0 then 
                player.money=0
                dprint "He doesn't seem very happy about you being unable to pay."
            else
                faction(0).war(1)-=5
            endif
        else
            basis(st).spy=3
            faction(0).war(1)+=15
        endif
    endif
    
    if st<>player.lastvisit.s or player.turn-player.lastvisit.t>600 then
        b=0
        for a=1 to 20
            if makew(a,st)<>0 then 
                b+=1
                wsinv(b)=makeweapon(makew(a,st))
            endif
        next
    endif
    
    
    if st<>player.lastvisit.s or player.turn-player.lastvisit.t>100 then
        gainxp(1)
        player=checkquestcargo(player,st)
        'change_prices(st,(player.turn-player.lastvisit.t)\3)
        questroll=rnd_range(1,100)-10*(crew(1).talents(3))
        for a=0 to 2
            companystats(basis(a).company).rate=0
            for b=0 to 1+(player.turn-player.lastvisit.t)\3
                companystats(basis(a).company).profit=companystats(basis(a).company).profit+((rnd_range(1,6)+rnd_range(1,6)-rnd_range(1,6)-rnd_range(1,6))*companystats(basis(a).company).capital/150)
                if companystats(basis(a).company).profit>0 then companystats(basis(a).company).rate=companystats(basis(a).company).rate+1
                if companystats(basis(a).company).profit<0 then companystats(basis(a).company).rate=companystats(basis(a).company).rate-1
            next
            companystats(basis(a).company).rate=companystats(basis(a).company).rate+(companystats(basis(a).company).capital+companystats(basis(a).company).profit)/10
            companystats(basis(a).company).profit=0
            if companystats(basis(a).company).rate<70 then companystats(basis(a).company).rate=70  
            if companystats(basis(a).company).rate>500 then companystats(basis(a).company).rate=500  
        next
        if companystats(basis(st).company).capital<300 then dprint "The spacestation is abuzz with rumors that "&companyname(basis(st).company) &" is in financial difficulties."
        if companystats(basis(st).company).capital<100 then 
            dprint companyname(basis(st).company) &" has closed their office in this station."
            dum=makecorp(-basis(st).company)
            basis(st).company=dum.company
            basis(st).repname=dum.repname
            basis(st).mapmod=dum.mapmod
            basis(st).biomod=dum.biomod
            basis(st).resmod=dum.resmod
            basis(st).pirmod=dum.pirmod
            dprint companyname(basis(st).company) &" has taken their place."
        endif
        dividend()
    endif
    girlfriends(st)
    hiringpool=rnd_range(1,4)+rnd_range(1,4)+3       
    do
        quarantine=player.disease
        mtext="Station "& st+1 &"/ "
        mtext=mtext & basis(st).repname &" Office "
        if quarantine>6 then mtext=mtext &"(Quar.)"
        mtext=mtext &"/ Equipment "
        if quarantine>6 then mtext=mtext &"(Quar.)"
        mtext=mtext &"/ Sickbay / Fuel(" & round_nr((basis(st).inv(9).p/30)*(player.fuelmax+player.fuelpod-player.fuel),2) & "Cr.) & Ammuniton(" & missing_ammo*player.loadout & "Cr.) / "
        mtext=mtext &"Repair(" &(max_hull(player)-player.hull)*100 & "Cr.) / Hire Crew / Trading "
        if quarantine>5 then mtext=mtext &"(Quar.)"
        mtext=mtext &"/ Casino "
        if quarantine>4 then mtext=mtext &"(Quar.)"
        mtext=mtext &"/ Retirement"
        mtext=mtext &"/Leave station"
        display_ship()
        a=menu(mtext,,,,,1)
        if a=1 then 
            if quarantine<8 then
                company(st,questroll)
            else
                dprint "you are under quarantine and not allowed to enter there"
            endif
        endif
        if a=2 then'refit
            if quarantine<9 then
                do
                    cls
                    display_ship()
                    b=menu("Refit/Hull/Ships Upgrades & Weapons/Personal Equipment/Exit")
                    if b=1 then shipyard()            
                    if b=2 then shipupgrades(st)
                    'if b= then towingmodules
                    if b=3 then 'awayteam equipment
                        do
                            c=shop(st,1,"Equipment")
                            display_ship
                        loop until c=-1
                        cls
                    endif
                loop until b=4
            else
                dprint "you are under quarantine and not allowed to enter there"
            endif
        endif
        if a=3 then 
            player.disease=sickbay()
            mtext="Station "& st+1 &"/ "
            mtext=mtext & basis(st).repname &" Office "
            if quarantine>6 then mtext=mtext &"(Quar.)"
            mtext=mtext &"/ Equipment "
            if quarantine>6 then mtext=mtext &"(Quar.)"
            mtext=mtext &"/ Sickbay / Fuel & Ammuniton / Repair / Hire Crew / Trading "
            if quarantine>5 then mtext=mtext &"(Quar.)"
            mtext=mtext &"/ Casino "
            if quarantine>4 then mtext=mtext &"(Quar.)"
            mtext=mtext &"/Exit"            
        endif
        if a=4 then refuel(st,round_nr(basis(st).inv(9).p/30,2))
        if a=5 then repairhull()            
        if a=6 then hiring(st,hiringpool,4)            
        if a=7 then 
            if quarantine<7 then
                trading(st)
            else
                dprint "you are under quarantine and not allowed to enter there"
            endif
        endif
        if a=8 then 
            if quarantine<5 then
                b=casino(0,st)
            else
                dprint "you are under quarantine and not allowed to enter there"
            endif
        endif
        if a=9 then retirement()
        if a=10 or a=-1 then
            text=""
            if player.pilot(0)<0 then text=text &"You dont have a pilot. "
            if player.gunner(0)<0 then text=text &"You dont have a gunner. "
            if player.science(0)<0 then text=text &"You dont have a science officer. "
            if player.doctor(0)<0 then text=text &"You dont have a ships doctor. "
            if player.fuel<player.fuelmax*0.5 then text=text &"You only have " &player.fuel & " fuel. "
            if player.money<0 then text=text &"You still have debts of "& player.money &" credits to pay. "
            if (text<>"" and player.dead=0) then
                if askyn(text &"Do you want to leave anyway?(y/n)",14) then
                    a=10
                else 
                    a=0
                endif
            endif
            if text="" and a=-1 then
                if askyn("Do you really want to leave?(y/n)",14) then
                    a=10
                else
                    a=0
                endif
            endif
        endif
    loop until a=10
    cls
    player.lastvisit.s=st
    player.lastvisit.t=player.turn
    return player
end function



function move_ship(key as string) as _ship
    dim as short a,dam,hydrogenscoop
    dim scoop as single
    static fuelcollect as byte
    dim old as _cords
    if artflag(23)>0 then
        if player.hull<player.h_maxhull and player.turn mod 10=0 then player.hull+=1
    endif
    hydrogenscoop=0
    for a=1 to player.h_maxweaponslot
        if player.weapons(a).made=85 then hydrogenscoop+=1
        if player.weapons(a).made=86 then hydrogenscoop+=2
    next
    if walking=0 then
        a=getdirection(key)
    else
        if walking<10 then a=walking
    endif
    if walking=10 then
        currapwp+=1
        a=nearest(apwaypoints(currapwp),player.c)
        if currapwp=lastapwp then
            dprint "Target reached"
            walking=0
        endif
        
    endif
    if a<>0 then player.di=a
    old=player.c 
    player.c=movepoint(player.c,a,,1)
    if player.c.x<0 then player.c.x=0
    if player.c.y<0 then player.c.y=0
    if player.c.x>sm_x then player.c.x=sm_x
    if player.c.y>sm_y then player.c.y=sm_y
    if player.c.x<>old.x or player.c.y<>old.y then 
        if player.towed<>0 then player.fuel-=1
        if player.towed<>0 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)<9 then player.fuel-=1
        if spacemap(player.c.x,player.c.y)=-2 then spacemap(player.c.x,player.c.y)=2
        if spacemap(player.c.x,player.c.y)=-3 then spacemap(player.c.x,player.c.y)=3
        if spacemap(player.c.x,player.c.y)=-4 then spacemap(player.c.x,player.c.y)=4
        if spacemap(player.c.x,player.c.y)=-5 then spacemap(player.c.x,player.c.y)=5
        if spacemap(player.c.x,player.c.y)=-6 then spacemap(player.c.x,player.c.y)=6
        if spacemap(player.c.x,player.c.y)=-7 then spacemap(player.c.x,player.c.y)=7
        if spacemap(player.c.x,player.c.y)=-8 then spacemap(player.c.x,player.c.y)=8
        if spacemap(player.c.x,player.c.y)>=2 and spacemap(player.c.x,player.c.y)<=5 and _warnings=0 then        
            if not(askyn("Do you really want to enter the gascloud?(y/n)")) then player.c=old
        endif
        if spacemap(player.c.x,player.c.y)>=2 and spacemap(player.c.x,player.c.y)<=5 then        
            player.towed=0
            if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>6+spacemap(player.c.x,player.c.y) then
                dprint "You succesfully navigate the gascloud",10
                if hydrogenscoop=0 then player.fuel=player.fuel-rnd_range(1,3)
                fuelcollect+=spacemap(player.c.x,player.c.y)*hydrogenscoop
                if fuelcollect>5 then
                    player.fuel+=fuelcollect/5
                    if player.fuel>player.fuelmax then player.fuel=player.fuelmax
                    fuelcollect=06
                endif
            else
                dam=rnd_range(0,3)+spacemap(player.c.x,player.c.y)
                if dam>player.shield then
                    dam=dam-player.shield
                    dprint "Your Ship is damaged("&dam &")",12
                    player.hull=player.hull-dam
                    player.fuel=player.fuel-rnd_range(1,5)
                    if player.hull<=0 then player.dead=12
                endif
            endif
        endif
        if spacemap(player.c.x,player.c.y)>=6 and spacemap(player.c.x,player.c.y)<=20 then 
            select case spacemap(player.c.x,player.c.y)
            case is=16
                dprint "This anomaly shortens space."
            case is=17
                dprint "This anomaly lengthens space."
            case is=18
                dprint "This anomaly shortnes space, and can damage a ship."
            case is=19
                dprint "This anomaly lengthens space, and can damage a ship."
            case is=20
                dprint "This anomaly can damage a ship and is highly unpredictable."
            end select
            if (spacemap(player.c.x,player.c.y)>=8 and spacemap(player.c.x,player.c.y)<=10) or (spacemap(player.c.x,player.c.y)>=18 and spacemap(player.c.x,player.c.y)<=20) then
                if rnd_range(1,100)<15 then
                    dam=rnd_range(0,3)
                    if dam>player.shield then
                        dam=1
                        dprint "Your Ship is damaged("&dam &")",12
                        player.hull=player.hull-dam
                        player.fuel=player.fuel-rnd_range(1,5)
                        if player.hull<=0 then player.dead=30
                    else
                        if player.shield>0 then dprint "Your shields are hit, but hold",10
                    endif
                endif
            endif
            if spacemap(player.c.x,player.c.y)=8 or spacemap(player.c.x,player.c.y)=6 or spacemap(player.c.x,player.c.y)=18 or spacemap(player.c.x,player.c.y)=16 then
                player.energy-=2
                player.fuel+=.5
            endif
            if spacemap(player.c.x,player.c.y)=9 or spacemap(player.c.x,player.c.y)=7 or spacemap(player.c.x,player.c.y)=19 or spacemap(player.c.x,player.c.y)=17 then
                player.energy+=10
                player.fuel-=.5
            endif
            if spacemap(player.c.x,player.c.y)=10 or spacemap(player.c.x,player.c.y)=20 or (spacemap(player.c.x,player.c.y)>=6 and rnd_range(1,100)<5) then 
                if rnd_range(1,100)<66 then
                    select case rnd_range(0,100)
                    case is=1
                        dprint "Something strange is happening with your fuel tank reading"
                        player.fuel+=rnd_range(1,6)
                    case is=2
                        dprint "You get swept away in a gravitational current"
                        player.c=old
                    case is=3
                        dprint "You get swept away in a gravitational current"
                        player.c=movepoint(player.c,player.di,,1)
                    case is=4
                        dprint "You get swept away in a gravitational current"
                        player.c=movepoint(player.c,5,,1)
                    case is=5
                        dprint "Something strange is happening with the ships chronometer"
                        player.turn=player.turn+rnd_range(1,6)-rnd_range(1,8)
                    case is=6
                        dprint "Your sensors are damaged."
                        player.sensors-=1
                    case is=7
                        if player.shield>0 then
                            dprint "Your shields are damaged."
                            player.shield-=1
                        endif
                    case is=8
                        dprint "Time itself seems to speed up"
                        player.energy=player.engine+20-player.engine*2
                    case is=9
                        dprint "You have trouble keeping your position"
                        player.di=rnd_range(1,8)
                        if player.di=5 then player.di=9
                    case is=10
                        dprint "Something catapults you out of the anomaly!"
                        for a=0 to rnd_range(1,6)
                            player.c=movepoint(player.c,player.di,,1)
                        next
                    case is=11
                        if rnd_range(1,100)+player.pilot(0)<10+spacemap(player.c.x,player.c.y) then 
                            player.c=map(rnd_range(laststar+1,laststar+wormhole)).c
                            dam=rnd_range(1,6)
                            if dam>player.shield then
                                dam=1
                                dprint "your Ship is damaged("&dam &")",12
                                player.hull=player.hull-dam
                                player.fuel=player.fuel-rnd_range(1,5)
                                if player.hull<=0 then player.dead=30
                            endif
                        else
                            dprint "A wormhole forms straight ahead, but you manage to avoid it. It disappears again instantly."
                        endif
                    case is=12
                        dprint "There should be a *lot* less fuel in your fueltank"
                        player.fuel+=rnd_range(50,100)
                    case is=13
                        dprint "This strange area of space alters your ships structure"
                        player.h_maxhull-=1
                    case is=14
                        dprint "This strange area of space alters your ships structure"
                        player.h_maxhull+=1
                    case is=15
                        dprint "Your cargo hold is damaged!"
                        player.cargo(rnd_range(1,player.h_maxcargo)).x=1
                    case is =16
                        dprint "Your fuel tank is damaged!"
                        player.h_maxfuel-=1
                        if rnd_range(1,100)<10 then
                            dprint "The damage results in an explosion!"
                            player.hull-=rnd_Range(1,3)
                        endif
                    end select
                    
                endif
            endif
'            player.turn=player.turn-rnd_range(1,6)+rnd_range(1,6)
'            player.energy=player.energy-rnd_range(1,6)+rnd_range(1,6)
'            if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>7 then
'                if spacemap(player.c.x,player.c.y)=6 then player.fuel=player.fuel-1
'                if spacemap(player.c.x,player.c.y)=7 then player.fuel=player.fuel-1.5
'                if spacemap(player.c.x,player.c.y)=8 then player.fuel=player.fuel-.3
'                if spacemap(player.c.x,player.c.y)>8 then 
'                    if a=spacemap(player.c.x,player.c.y)-8 then
'                        player.fuel=player.fuel-.3
'                    else
'                        player.fuel=player.fuel-2.5
'                    endif
'                    if rnd_range(1,20)>player.engine then
'                        player.c=movepoint(player.c,a)
'                        dprint "Your ship is swept away in a gravitational current!",14
'                    endif
'                endif
'                old=player.c
'                dprint "You succesfully navigate the anomaly",10
'            else
'                dam=rnd_range(0,3)
'                if dam>player.shield then
'                    dam=1
'                    dprint "Your Ship is damaged",12
'                    player.hull=player.hull-dam
'                    player.fuel=player.fuel-rnd_range(1,5)
'                    if player.hull<=0 then player.dead=30
'                else
'                    dprint "Your shields are hit, but hold",10
'                endif
'            endif
'            if rnd_range(1,100)+player.pilot(0)<10+spacemap(player.c.x,player.c.y) then 
'                player.c=movepoint(player.c,5,,1)
'                if rnd_range(1,100)+player.pilot(0)<10+spacemap(player.c.x,player.c.y) then 
'                    player.c=map(rnd_range(laststar+1,laststar+wormhole)).c
'                    dam=rnd_range(1,6)
'                    if dam>player.shield then
'                        dam=1
'                        dprint "your Ship is damaged",12
'                        player.hull=player.hull-dam
'                        player.fuel=player.fuel-rnd_range(1,5)
'                        if player.hull<=0 then player.dead=30
'                    endif
'                endif
'            endif
        endif
        if player.towed>0 then
            drifting(player.towed).x=player.c.x
            drifting(player.towed).y=player.c.y
        endif
    endif
    if (player.c.x<>old.x or player.c.y<>old.y) and (player.c.x+player.osx<>30 or player.c.y+player.osy<>10) then 
        if spacemap(player.c.x,player.c.y)<=5 then player.fuel=player.fuel-player.fueluse
        player.energy+=10
    else
        walking=0
    endif
    return player
end function

function explore_space() as short
    dim as short a,b,d,c,f,fl,pl,x1,y1,x2,y2,lturn,debug
    dim as string key,text,allowed
    dim as _cords p1,p2
    dim as short planetcom,driftercom,fleetcom,wormcom
    lturn=0
    
    do
        if debug=8 then dprint "Lastfleet:"&lastfleet
    lturn+=1
    if lturn>=5 then
        player.turn+=1
        lturn=0
    endif
    if show_specials<>0 then dprint "Planet is at " &map(sysfrommap(specialplanet(show_specials))).c.x &":"&map(sysfrommap(specialplanet(show_specials))).c.y
    if player.energy<=0 and player.dead=0 then
        fl=0
        allowed=key_awayteam & key_ra & key_probe &key_la &key_tala &key_dock &key_sc & key_rename & key_comment & key_save &key_quit &key_tow &key_walk
        allowed= allowed & key_nw & key_north & key_ne & key_east & key_west & key_se & key_south & key_sw
        if debug=11 then allowed=allowed &"�"
        for a=0 to 2
            if player.c.x=basis(a).c.x and player.c.y=basis(a).c.y then
                dprint "You are at Spacestation-"& a+1 &". Press "&key_dock &" to dock."
                allowed=allowed & key_fi
                if walking<10 then walking=0
                driftercom=1
            endif
        next
        
        for a=1 to lastfleet
            if distance(player.c,fleet(a).c)<1.5 then 
                fl=meet_fleet(a)
                fleetcom=1
                exit for
            endif
        next    
        for a=0 to laststar
            if player.c.x=map(a).c.x and player.c.y=map(a).c.y then
                planetcom=a+1
                dPrint "A "&spectralname(map(a).spec)& ". Press "&key_sc &" to scan, "&key_la &" to land, " &key_tala &" to land at a specific spot."
                if a=piratebase(0) then dprint "Lots of traffic in this system"
                map(a).discovered=2
                display_system(a)
                if walking<10 then walking=0
            endif
        next
        for a=laststar+1 to laststar+wormhole
            if player.c.x=map(a).c.x and player.c.y=map(a).c.y then
                dprint "A wormhole. Press "&key_la &" to enter it."
                wormcom=1
                if walking<10 then walking=0
            endif
        next
        for a=1 to lastdrifting
            if player.c.x=drifting(a).x and player.c.y=drifting(a).y and planets(drifting(a).m).flags(0)=0 and player.towed<>a then
                if player.tractor>0 and a>3 then dprint "A "&shiptypes(drifting(a).s)&" is drifting in space here. "&key_dock &" to dock. "&key_tow &" to tow."
                if player.tractor=0 then dprint "A "&shiptypes(drifting(a).s)&" is drifting in space here. "&key_dock &" to dock."
                drifting(a).p=1
                driftercom=1
                if walking<10 then walking=0
            endif
        next
        if fl>0 or _testspacecombat=1 then
            if fleet(fl).ty=1 and fl>5 then dprint "There is a merchant convoy in sensor range, hailing us. press "&key_fi &" to attack," &key_ra & " to call by radio."
            if fleet(fl).ty=2 then dprint "There is a pirate fleet in sensor range, hailing us. press "&key_fi &" to attack, " &key_ra & " to call by radio."
            if fleet(fl).ty=3 then dprint "There is a company anti pirate patrol in sensor range, hailing us. press "&key_fi &" to attack, " &key_ra & " to call by radio."
            if fleet(fl).ty=4 then dprint "There is a pirate fleet in sensor range, hailing us. press "&key_fi &" to attack, " &key_ra & " to call by radio."
            if fleet(fl).ty=6 then
                if civ(0).contact=0 then
                    dprint civfleetdescription(fleet(fl)) &" hailing us. Press "& key_fi &"to attack, " &key_ra & " to call by radio."
                else
                    dprint "A "&civ(0).n &" fleet, hailing us. Press "& key_fi &"to attack, " &key_ra & " to call by radio."
                endif        
            endif
            allowed=allowed+key_fi
            fleetcom=1
        endif
        
        comstr=key_ra &" call by radio;"&key_probe &" launch probe;"&key_comment &" comment;" 
        if planetcom>0 then comstr=comstr & key_sc &" scan;"& key_la &" land;"& key_tala &" target land;"
        if fleetcom=1 then comstr=comstr &key_fi &" attack;"
        if driftercom=1 then comstr=comstr &key_dock &" dock;"&key_tow &" traktor beam;"
        if wormcom=1 then comstr=comstr &key_la &" enter wormhole"
        
        display_ship(1)
        if planetcom>0 then display_system(planetcom-1)
        key=keyin(allowed,walking)
        player=move_ship(key)
        
        planetcom=0
        fleetcom=0
        driftercom=0
        wormcom=0
        comstr=key_ra &" call by radio;"&key_probe &" launch probe;"&key_comment &" comment;" 
        
        
        if debug=11 and key="�" then
            dprint fleet(1).mem(1).hull &":"&fleet(2).mem(1).hull &":"&fleet(3).mem(1).hull 
            lastfleet=8
            fleet(6)=makealienfleet
            fleet(6).c=basis(0).c
            fleet(7)=makealienfleet
            fleet(7).c=basis(1).c
            fleet(8)=makealienfleet
            fleet(8).c=basis(2).c
        endif
            
        if key=key_fi then
            for a=0 to 2
                if player.c.x=basis(a).c.x and player.c.y=basis(a).c.y then
                    if askyn( "Do you really want to attack Spacestation-"& a+1 &")(y/n)") then
                        factionadd(0,fleet(a+1).ty,20)
                
                        playerfightfleet(a+1)
                        if player.dead=0 then
                            if fleet(a+1).mem(1).hull<=0 then
                                dprint "Station "&a+1 &" has been destroyed"
                                basis(a+1).c.x=-1
                                fleet(a+1).c.x=-1
                            endif
                        endif
                    endif
                endif
            next
            if _testspacecombat=1 then fl=rnd_range(4,lastfleet)
            if fl>0 then 
                factionadd(0,fleet(fl).ty,20)
                
                playerfightfleet(fl)
            endif
        endif
            
        if key=key_walk then
            key=keyin
            walking=getdirection(key)
        endif
        
        if key=key_ra then space_radio
        
        if key=key_probe then launch_probe
        
        if key=key_la or key=key_tala or key=key_sc then
            pl=-1
            for a=0 to laststar
                if player.c.x=map(a).c.x and player.c.y=map(a).c.y then pl=a
            next
            
            if pl>-1 then
                if key=key_la or key=key_tala then 
                    a=getplanet(pl)
                    if a>0 then
                        b=map(pl).planets(a)
                        if isgasgiant(b)=0 and b>0 then
                            if key=key_la then landing(map(pl).planets(a))
                            if key=key_tala then targetlanding(map(pl).planets(a))
                        else
                            if isgasgiant(b)=0 then
                                dprint"You don't find anything big enough to land on"
                            else
                                gasgiantfueling(b,a,pl)
                            endif
                        endif
                    endif
                endif    
                if key=key_sc then scanning()
                key=""
            endif
            pl=-1
            
            if abs(spacemap(player.c.x,player.c.y))>=6 and abs(spacemap(player.c.x,player.c.y))<=10 then
                if askyn("Do you want to scan the anomaly?(y/n)") then
                    if rnd_range(1,6)+rnd_range(1,6)+player.science(0)>=3+abs(spacemap(player.c.x,player.c.y)) then 
                        gainxp(4)
                        ano_money+=1
                        spacemap(player.c.x,player.c.y)=abs(spacemap(player.c.x,player.c.y))+10
                        select case spacemap(player.c.x,player.c.y)
                        case is=16
                            dprint "This anomaly shortens space."
                        case is=17
                            dprint "This anomaly lengthens space."
                        case is=18
                            dprint "This anomaly shortnes space, and can damage a ship."
                        case is=19
                            dprint "This anomaly lengthens space, and can damage a ship."
                        case is=20
                            dprint "This anomaly can damage a ship and is highly unpredictable."
                        end select
                    else
                        dprint "You are unable to identify the anomaly.",c_yel
                    endif
                endif
            endif
                    
            
            for a=laststar+1 to laststar+wormhole
                if player.c.x=map(a).c.x and player.c.y=map(a).c.y then pl=a
            next
            if pl>1 and key=key_la and _warnings=0 then
                if askyn("Travelling through wormholes can be dangerous. Do you really want to?(y/n)")=0 then pl=0 
            endif
            if pl>1 and key=key_la and rnd_range(1,100)<whtravelled then
                dprint "There is a planet orbiting the wormhole!"
                if askyn("Shall we try to land on it? (y/n)") then
                    if whplanet=0 then makewhplanet
                    pl=0
                    landing(whplanet)
                endif
                whtravelled=101
            endif
            if pl>1 and key=key_la then
                player.towed=0
                if map(pl).planets(2)=0 and whtravelled<101 then whtravelled+=1
                map(pl).planets(2)=1
                if artflag(16)=0 then
                    b=map(pl).planets(1)
                else
                    dprint "Wormhole navigation system engaged!(+/- to choose wormhole, "&key_la &" to select)",10
                    for c=laststar+1 to laststar+wormhole
                        map(c).discovered=1
                    next
                    do
                        player.osx=map(pl).c.x-30
                        player.osy=map(pl).c.y-10
                        if player.osx<=0 then player.osx=0
                        if player.osy<=0 then player.osy=0
                        if player.osx>=sm_x-60 then player.osx=sm_x-60
                        if player.osy>=sm_y-20 then player.osy=sm_y-20
                        display_ship
                        show_stars(2)
                        
                            
                        locate map(pl).c.y+1-player.osy,map(pl).c.x+1-player.osx
                        set__color( 0,11)
                        draw_string((map(pl).c.x-player.osx)*_fw1,(map(pl).c.y-player.osy)*_fh1, "o",font1,_col)
                        if player.c.x-player.osx>=0 and player.c.x-player.osx<=60 and player.c.y-player.osy>=0 and .y-player.osy<=20 then
                            set__color( _shipcolor,0)
                            draw_string((player.c.x-player.osx)*_fw1,( player.c.y-player.osy)*_fh1,"@",font1,_col)
                        endif
                        d=int(distance(player.c,map(pl).c))
                        dprint "Wormhole at "&map(pl).c.x &":"& map(pl).c.y &". Distance "&d &" Parsec."
                        key=keyin
                        if keyplus(key) then pl=pl-1
                        if keyminus(key) then pl=pl+1
                        if pl<laststar+1 then pl=laststar+wormhole
                        if pl>laststar+wormhole then pl=laststar+1
                        set__color( 11,0)
                        cls 
                    loop until key=key__enter or key=key_la
                    b=pl
                endif
                if map(b).planets(2)=0 then
                    ano_money+=cint(distance(map(b).c,player.c)*25)
                endif
                map(b).planets(2)=1
                dprint "you travel through the wormhole",10
                #ifdef _FMODSOUND
                if _sound=0 or _sound=2 then FSOUND_PlaySound(FSOUND_FREE, sound(5))                    
                #endif
                player.osx=player.c.x-30
                player.osy=player.c.y-10
                if player.osx<=0 then player.osx=0
                if player.osy<=0 then player.osy=0
                if player.osx>=sm_x-60 then player.osx=sm_x-60
                if player.osy>=sm_y-20 then player.osy=sm_y-20
                d=0
                if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)<8+int(distance(player.c,map(b).c)/3) and artflag(13)=0 then d=rnd_range(1,3)
                player.hull=player.hull-d
                if player.hull>0 then
                    wormhole_ani(map(b).c)
                    if d>0 then dprint "Your ship is damaged ("&d &").",14
                    display_ship(1)
                    show_stars(1)
                    dprint ""
                else
                    player.dead=24
                endif
            endif
        endif
        
        if key=key_dock then
            for a=0 to 3
                if player.c.x=basis(a).c.x and player.c.y=basis(a).c.y then
                    if stationroll=0 or player.lastvisit.s<>a then stationroll=rnd_range(1,20)
                    if faction(0).war(1)+stationroll<100 then
                        b=rnd_range(1,4)
                        if faction(0).war(1)>80 then
                            dprint "You have to beg to get a docking permission, exagerating the sorry state of your ship quite a bit in the process!",14
                            b=15
                        endif
                        if faction(0).war(1)>33 then
                            if b=1 then dprint "After an unusually long waiting period you get your permission to dock.",14
                            if b=2 then dprint "The Station commander questions you extensively about your activities before allowing you to dock.",14
                        endif
                        if faction(0).war(1)>66 then
                            if b=1 then dprint "After you dock you overhear a dock worker remark 'I didn't know we were allowing known pirates on the base.' He looks at you fully aware that you heard him.",14
                            if b=2 then dprint "A patrol boat captain bumps into you snarling 'Pirate scum. Wait till i meet you in space!'",14
                        endif
                        player=spacestation(a)
                        key=""
                        if _autosave=0 and player.dead=0 then 
                            screenset 1,1
                            dprint "Saving game",15
                            savegame()
                        endif
                        set__color( 11,0)
                        c=0
                        d=0
                        for b=0 to 10
                            if player.cargo(b).x>1 and player.cargo(b).x<7 then
                                c=c+basis(a).inv(player.cargo(b).x-1).p
                            endif
                        next
                        c=c\15
                        'dprint "pirate chance:" &c
                        if c>66 then c=66
                        ' Pirate agression test
                        for b=0 to 10
                            if player.cargo(b).x=7 then 
                                c=101
                                d=1
                            endif
                        next
                        if basis(a).spy=1 then c=0
                        for b=3 to lastfleet
                            if fleet(b).ty=2 and rnd_range(1,100)<c then
                                fleet(b).t=8
                                d=1
                            else
                                fleet(b).t=9
                            endif
                        next
                        'see if pirates notice
                        if d=1 then 
                            dprint "As you load your Cargo you notice a worker taking notes. When you want to question him he is gone."
                            no_key=keyin
                        endif
                        if player.money<0 and player.dead=0 then
                            if rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>12 then
                                dprint "As you leave the docking bay you get a message from the station commander to return to 'solve some financial issues' first. Your pilot grins and heads for the docking bay doors, exceeding savety limits. The doors slam close right behind your ship. As you speed into space you get a radio message from the commander. He calmly explains that there *will* be a fee for that next time you dock."
                                player.money=player.money-100
                                faction(0).war(2)-=1
                                faction(0).war(1)+=1
                            else
                                player.dead=2
                            endif
                        endif
                    else
                        dprint "The station commander closes the bay doors and fires upon you!",12
                        player.hull=player.hull-rnd_range(1,6)
                        if player.hull<=0 then player.dead=18
                        no_key=keyin
                    endif
                endif
            next
            screenset 1,1
            show_stars(1)
        endif
        
        if key=key_dock then
            for a=1 to lastdrifting
                if player.c.x=drifting(a).x and player.c.y=drifting(a).y and planets(drifting(a).m).flags(0)=0 then driftingship(a)
            next
        endif
        
        if key=key_tow then
            if player.towed=0 then
                for a=4 to lastdrifting
                    if player.c.x=drifting(a).x and player.c.y=drifting(a).y and planets(drifting(a).m).flags(0)=0 then 
                        if player.tractor>0 then
                            player.towed=a
                            dprint "You tow the other ship."
                        else
                            dprint "You have no tractor beam.",14
                        endif
                    endif
                next
            else
                player.towed=0
                dprint "You release the other ship."
            endif
        endif
        
        if key=key_awayteam then
            screenshot(1)
            showteam(0)
            screenshot(2)
        endif
        
        
        screenset 0,1
        
        cls
                
        show_stars(1)
        display_ship(1)
        dprint ""
        
        flip
        screenset 1,1
        
    else
        player.energy-=player.movepoints(0)
    endif
    clearfleetlist
    
    if lturn=0 then
        if frac(player.turn/10)=0 then 
            lastfleet=lastfleet+1
            if lastfleet>255 then lastfleet=3
            fleet(lastfleet)=makefleet(fleet(lastfleet))
            for a=0 to 2
                change_prices(a,10)
            next
        endif
        
        if frac(player.turn/25)=0 then 
            
            lastfleet=lastfleet+1
            if lastfleet>255 then lastfleet=6
            fleet(lastfleet)=makecivfleet(0)
            if show_npcs=3 then dprint ""&fleet(lastfleet).ty
            lastfleet=lastfleet+1
            if lastfleet>255 then lastfleet=6
            fleet(lastfleet)=makecivfleet(1)
            if show_npcs=3 then dprint ""&fleet(lastfleet).ty
        endif
        
        if frac(player.turn/100)=0 and player.turn>5000 and player.questflag(3)=0 then 
            lastfleet=lastfleet+1
            if lastfleet>255 then lastfleet=6
            fleet(lastfleet)=makealienfleet
            
        endif
        if player.turn mod 100=0 then
            for a=1 to lastquestguy
                if rnd_range(1,100)<25 and questguy(a).job=9 then questguy_newloc(a)
                if rnd_range(1,100)<25 and questguy(a).job<>1 then questguy_newloc(a)
            next
        endif
        move_fleets()
        collide_fleets()
        move_probes()
        
        for a=0 to 2
            if fleet(a).mem(1).hull<128 and fleet(a).mem(1).hull>0 then fleet(a).mem(1).hull+=3
        next
        
        diseaserun(0)
        if frac(player.turn/5)=0 then cureawayteam(1) 
        if frac(player.turn/250)=0 then 
            rerollshops
        endif
    endif
    
    if player.hull<=0 and player.dead=0 then player.dead=18
    if player.fuel<=0 and player.dead=0 then rescue()
    
    if key=key_save then
        if askyn("Do you really want to save the game? (y/n)") then player.dead=savegame()
    endif
    if key=key_rename then
        if askyn("Do you want to rename your ship? (y/n)") then
            set__color( 15,0)
            draw_string(63*_fw1,0, space(16),font2,_col)
            key=gettext(63*_fw1/_fw2,0,32,"")
            if key<>"" then player.desig=key
            set__color( 11,0)
            player.turn=player.turn-1
        endif
    endif
    
    if key=key_comment then 'Name or comment on map
        dim as short osx
        osx=p2.x-_mwx/2
        if osx<0 then osx=0
        if osx>=60-_mwx then osx=60-_mwx
    
        p2.x=player.c.x-player.osx
        p2.y=player.c.y-player.osy
        do
            key=cursor(p2,0,osx)
            show_stars(1)
            display_ship(1)
        loop until key=key__esc or key=key__enter or (asc(ucase(key))>64 and asc(key)<132)
        set__color( 11,0)
        
        b=0
        if key<>key__esc then
            for a=1 to lastcom
                if p2.y=coms(a).c.y-player.osy then
                    if p2.x>=coms(a).c.x-player.osx and p2.x<=coms(a).c.x-player.osx+coms(a).l then
                            key=trim(coms(a).t)
                            b=a
                            p2.x=coms(a).c.x
                            p2.y=coms(a).c.y
                    endif
                 endif
            next
            locate p2.y+1,p2.x+1
            text=gettext(p2.x*_fw1/_fw2,p2.y*_fh1/_fh2,16,key)
            text=trim(text)
            cls
            show_stars(1)
            display_ship(1)
            if b=0 then
                lastcom=lastcom+1
                b=lastcom
            endif
            if p2.x+player.osx+len(text)>sm_x then p2.x=sm_x-len(text)
            coms(b).c.x=p2.x+player.osx
            coms(b).c.y=p2.y+player.osy
            coms(b).t=text
            coms(b).l=len(text)
            dprint " "& b
        endif
        b=0
        for a=1 to lastcom
            if coms(a).t="" then
                coms(a)=coms(a+1)
            else
                b=b+1
            endif
        next
        cls
        lastcom=b
        show_stars(1)
        display_ship(1)
    endif 
    
    
    if player.turn mod 10 =0 then clean_station_event
    
    if frac(player.turn/500)=0 then 
        for a=0 to 2
            colonize_planet(a)
        next
        grow_colonies
    endif
    
    for a=0 to laststar
        if map(a).planets(1)>0 then
            if planets(map(a).planets(1)).flags(27)=2 then 
                planets(map(a).planets(1)).death-=1 
                if planets(map(a).planets(1)).death<=0 then
                    map(a).planets(1)=0
                endif
            endif
        endif
    next
    
    if make_files=1 and frac(player.turn/10)=0 then
        f=freefile
        open "fleets.txt" for append as #f
        print #f,player.turn
        for a=1 to lastfleet
            print #f,a;" ";fleet(a).ty;" ";debug_printfleet(fleet(a))
        next
        close #f
    endif
    
    
    for a=0 to 7
        for b=0 to 7
            if faction(a).war(b)>100 then faction(a).war(b)=100 
            if faction(a).war(b)<0 then faction(a).war(b)=0 
        next
    next
    
    for a=0 to 7
        if faction(a).alli<>0 then
            for b=0 to 7
                faction(a).war(b)=(faction(a).war(b)+faction(faction(a).alli).war(b))/2
            next
            
        endif
    next
    
    driftercom=0
    planetcom=0
    fleetcom=0
    wormcom=0
        
'    if player.pirate_agr>500 then player.pirate_agr=500
'    if player.pirate_agr<-500 then player.pirate_agr=-500
'    if player.merchant_agr>500 then player.merchant_agr=500
'    if player.merchant_agr<-500 then player.merchant_agr=-500
'    if player.pirate_agr<=0 then
'        fightmatrix(0,2)=0
'        fightmatrix(2,0)=0
'        fightmatrix(0,4)=0
'        fightmatrix(4,0)=0
'    endif
'    if player.pirate_agr>=100 then
'        fightmatrix(0,2)=1
'        fightmatrix(2,0)=1
'        fightmatrix(0,4)=1
'        fightmatrix(4,0)=1
'    endif
'    if player.merchant_agr<=0 then
'        fightmatrix(0,1)=0
'        fightmatrix(1,0)=0
'        fightmatrix(0,3)=0
'        fightmatrix(3,0)=0
'    endif
'    if player.merchant_agr>=100 then
'        fightmatrix(0,1)=1
'        fightmatrix(1,0)=1
'        fightmatrix(0,3)=1
'        fightmatrix(3,0)=1
'    endif
loop until player.dead>0

    return 0
end function



function explore_planet(awayteam as _monster, from as _cords, orbit as short) as _cords
    dim as single a,b,c,d,e,f,g,x,y,sf,sf2,vismod
     
    dim as short slot,r,deadcounter,ship_landing,loadmonsters,allroll(7),osx
    dim as single dawn,dawn2
    dim as string key,dkey,allowed,text,help
    dim dam as single
    dim as _cords p,p1,p2,p3,nextlanding,old
    dim as _cords ship,nextmap
    dim towed as _ship
    dim enemy(255) as _monster
    dim m(255) as single
    dim as short skill
    dim mapmask(60,20) as byte
    dim vismask(60,20) as byte
    dim nightday(60) as byte
    dim watermap(60,20) as byte
    dim localtemp(60,20) as single
    dim cloudmap(60,20) as byte
    dim spawnmask(1281) as _cords
    dim lsp as short
    dim ti as short
    'dim localitem(128) as items
    dim li(256) as short
    dim lastlocalitem as short
    dim lastenemy as short
    dim diesize as short
    dim localturn as short
    dim tb as single
    'dim oxydep as single
    dim lavapoint(5) as _cords
    dim shipfire(16) as _shipfire
    dim areaeffect(16) as _ae
    dim autofire_dir as short
    dim autofire_target as _cords
    dim last_ae as short
    dim del_rec as _rect
    
    dim as short debug=0
'oob suchen
    screenset 1,1
    cls
    flip
    cls
    slot=from.m
    planets(slot).mapstat=2
    deadcounter=0
    awayteam.c=from
    ship=player.landed
    player.map=slot
    cls
    lsp=0    
    
    for a=1 to 20
        if makew(a,1)<>0 then 
            b+=1
            wsinv(b)=makeweapon(makew(a,1))
        endif
    next
    
    
    for x=0 to 60
        for y=0 to 20
            if abs(planetmap(x,y,slot))=1 then watermap(x,y)=10
            if abs(planetmap(x,y,slot))=2 then watermap(x,y)=50
            if planets(slot).depth=0 then
                localtemp(x,y)=planets(slot).temp-abs(10-y)*5+10
            else
                localtemp(x,y)=planets(slot).temp
            endif
            if show_all=1 and planetmap(x,y,slot)<0 then planetmap(x,y,slot)=-planetmap(x,y,slot)
            if abs(planetmap(x,y,slot))>512 then
                dprint "ERROR: Tile #"&planetmap(x,y,slot)&"out ofbounds"
                planetmap(x,y,slot)=512
            endif
            tmap(x,y)=tiles(abs(planetmap(x,y,slot)))
            if abs(planetmap(x,y,slot))=267 then tmap(x,y).desc="A cage. Inside is "&makemonster(1,slot).ldesc
            mapmask(x,y)=0
            if tmap(x,y).walktru=0 then
                lsp=lsp+1
                spawnmask(lsp).x=x
                spawnmask(lsp).y=y
            endif
            if tmap(x,y).vege>0 then 
                tmap(x,y).vege=rnd_range(0,tmap(x,y).vege)
                if rnd_range(1,100)<tmap(x,y).vege/2 then tmap(x,y).disease=rnd_range(0,tmap(x,y).vege/2)
            endif
            if rnd_range(1,100)<planets(slot).atmos and planets(slot).atmos>1 and planets(slot).depth=0 then cloudmap(x,y)=1
            if planetmap(x,y,slot)=0 then
                f=freefile
                open "error.log" for append as #f
                print #f,"Tile at "&x &":"&y &":"&slot &"=0"
                close #f
                planetmap(x,y,slot)=-4
            endif
        next
    next
    
    
    
    'allowed="12346789ULXFSQRWGCHDO"&key_pickup &key__i
    allowed=key_awayteam &key_ju & key_te & key_fi &key_save &key_quit &key_ra &key_walk & key_gr & key_he
    allowed=allowed & key_la & key_pickup & key__i & key_ex & key_of & key_co & key_drop & key_gr & key_wait 
    allowed=allowed & key_portal &key_oxy &key_close & key_report &key_autofire &key_autoexplore
    comstr=key_ex &" examine;" &key_fi &" fire,"&key_autofire &" autofire;" &key_autoexplore &" autoexplore;"
    comstr=comstr & key_gr &" grenade;" &key_oxy &" open/close helmet;" &key_close &" close door;" &key_drop &" Drop;"
    comstr=comstr & key_he &" use medpack;" &key_report &" bioreport;"&key_ra &" radio;"
            
    if rev_map=1 then allowed=allowed &"�"
    if awayteam.move=2 or awayteam.move=3 then 
        allowed=allowed &key_ju
        comstr=comstr &key_ju &" Jetpackjump;"
    endif
    if awayteam.move=4 then 
        allowed=allowed &key_te
        comstr=comstr &key_te &" Teleport;"
    endif
    
    if planets(slot).atmos=0 then planets(slot).atmos=1
    if planets(slot).grav=0 then planets(slot).grav=.5
    
    if planets(slot).atmos>1 and planets(slot).atmos<8 then 
        awayteam.helmet=0
        awayteam.oxygen=awayteam.oxymax
    else
        awayteam.helmet=1
    endif
    
    b=0
    for a=1 to 15 'Look for saved status on this planet
        if savefrom(a).map=slot then
            lastenemy=savefrom(a).lastenemy
            for b=1 to lastenemy
                enemy(b)=savefrom(a).enemy(b)
            next
            loadmonsters=1
        endif
    next
    
    if loadmonsters=0 then 'No saved status, monsters need to be generated
        c=0
        for a=0 to 16
            if planets(slot).mon_noamin(a)>0 and planets(slot).mon_noamax(a)>0 then
                if planets(slot).mon_template(a).made=0 then planets(slot).mon_template(a)=makemonster(1,slot)
                for d=1 to rnd_range(planets(slot).mon_noamin(a),planets(slot).mon_noamax(a))
                    c+=1
                    enemy(c)=setmonster(planets(slot).mon_template(a),slot,spawnmask(),lsp,vismask(),,,c,1)
                    enemy(c).slot=a
                    enemy(c).no=c
                    if enemy(c).faction=0 then enemy(c).faction=8+a
                    if enemy(c).faction<8 then
                        if allroll(enemy(c).faction)=0 then allroll(enemy(c).faction)=rnd_range(1,100)
                        if faction(0).war(enemy(c).faction)>=allroll(enemy(c).faction) then 
                            enemy(c).aggr=0
                        else
                            enemy(c).aggr=1
                        endif
                    endif
                next
            endif
        next
        lastenemy=c
        
        x=0
        for a=0 to lastspecial
            if specialplanet(a)=slot then x=1
        next
        for a=0 to _NoPB
            if pirateplanet(a)=slot then x=1
        next
        for a=1 to lastdrifting
            if drifting(a).m=slot then x=1
        next
        
        space_next_to_wall
        
        if planets(slot).visited=0 and planets(slot).depth=0 and x=0 then 
            combon(0).value+=1
            adaptmap(slot,enemy(),lastenemy) 
            lsp=0
            for x=0 to 60
                for y=0 to 20
                    if abs(planetmap(x,y,slot))=1 then watermap(x,y)=10
                    if abs(planetmap(x,y,slot))=2 then watermap(x,y)=50
                    localtemp(x,y)=planets(slot).temp-abs(10-y)*5+10
                    if show_all=1 and planetmap(x,y,slot)<0 then planetmap(x,y,slot)=-planetmap(x,y,slot)
                    tmap(x,y)=tiles(abs(planetmap(x,y,slot)))
                    if abs(planetmap(x,y,slot))=267 then tmap(x,y).desc="A cage. Inside is "&makemonster(1,slot).ldesc
                    mapmask(x,y)=0
                    if tmap(x,y).walktru=0 then
                        lsp=lsp+1
                        spawnmask(lsp).x=x
                        spawnmask(lsp).y=y
                    endif
                    if tmap(x,y).vege>0 then 
                        tmap(x,y).vege=rnd_range(0,tmap(x,y).vege)
                        if rnd_range(1,100)<tmap(x,y).vege/2 then tmap(x,y).disease=rnd_range(0,tmap(x,y).vege/2)
                    endif
                next
            next
            
            if rnd_range(1,100)<5 and rnd_range(1,100)<disnbase(player.c) and lastenemy>10 and planets(slot).atmos>1 then
                lastenemy=lastenemy+1
                enemy(lastenemy)=makemonster(46,slot)
                enemy(lastenemy)=setmonster(enemy(lastenemy),slot,spawnmask(),lsp,vismask(),,,lastenemy,1)
                enemy(lastenemy).slot=16
                enemy(lastenemy).no=lastenemy
                if rnd_range(1,100)<disnbase(player.c)*2 then placeitem(makeitem(81),enemy(lastenemy).c.x,enemy(lastenemy).c.y,slot)
            endif        
            if rnd_range(1,100)<26-disnbase(player.c) then 'deadawayteam 
                lastenemy=lastenemy+1
                enemy(lastenemy)=makemonster(15,slot)
                enemy(lastenemy)=setmonster(enemy(lastenemy),slot,spawnmask(),lsp,vismask(),,,lastenemy,1)
                enemy(lastenemy).hp=-1
                enemy(lastenemy).hpmax=55
                enemy(lastenemy).slot=16
                if show_all=1 then dprint "corpse at "&enemy(lastenemy).c.x & enemy(lastenemy).c.y
            endif
            if rnd_range(1,100)<26-distance(player.c,civ(0).home) then
                lastenemy+=1
                enemy(lastenemy)=setmonster(civ(0).spec,slot,spawnmask(),lsp,vismask(),,,lastenemy,1)
                enemy(lastenemy).hp=-1
                enemy(lastenemy).slot=16
            endif
            if rnd_range(1,100)<26-distance(player.c,civ(1).home) then
                lastenemy+=1
                enemy(lastenemy)=setmonster(civ(1).spec,slot,spawnmask(),lsp,vismask(),,,lastenemy,1)
                enemy(lastenemy).hp=-1
                enemy(lastenemy).slot=16
            endif
        endif
        if slot=pirateplanet(0) then
            for x=0 to 60
                for y=0 to 20
                    if abs(planetmap(p.x,p.y,slot))=246 then
                        changetile(p.x,p.y,slot,68)
                        tmap(p.x,p.y)=tiles(68)
                    endif
                next
            next
            if rnd_range(1,100)<25 then
                do
                    p=rnd_point(slot,,68)
                loop until tmap(p.x,p.y).gives=0
                planetmap(p.x,p.y,slot)=-246
                tmap(p.x,p.y)=tiles(246)
            endif
        endif
        
        for c=0 to 8
        b=(planets(slot).vault(c).h-2)*((planets(slot).vault(c).w-2))
        if b>4 or planets(slot).vault(c).wd(5)=4 then
            if debug=1 then dprint "Making vault at "&planets(slot).vault(c).x &":"& planets(slot).vault(c).y &":"& planets(slot).vault(c).w &":"& planets(slot).vault(c).h 
            if planets(slot).vault(c).wd(16)=99 then specialflag(15)=1
            if planets(slot).vault(c).wd(5)=1 then
                if b>9 then
                    lastenemy=lastenemy-rnd_range(1,6)
                    if lastenemy<1 then lastenemy=1
                    a=lastenemy+1
                    for x=planets(slot).vault(c).x+1 to planets(slot).vault(c).x+planets(slot).vault(c).w-1
                        for y=planets(slot).vault(c).y+1 to planets(slot).vault(c).y+planets(slot).vault(c).h-1
                            if a>255 then a=255
                            enemy(a)=makemonster(9,slot)
                            enemy(a)=setmonster(enemy(a),slot,spawnmask(),lsp,vismask(),x,y,a,1)
                            a=a+1
                        next
                    next 
                    lastenemy=a
                    if lastenemy>255 then lastenemy=255
                endif
            endif
            
            if planets(slot).vault(c).wd(5)=2 and planets(slot).vault(c).wd(6)<>0 then
                b=rnd_range(1,4)+rnd_range(1,4)+planets(slot).depth
                d=lastenemy
                if debug=1 then dprint "lastenemy"&lastenemy
                lastenemy=lastenemy+b
                for e=d to lastenemy
                    text=text &d
                    do
                        x=rnd_range(planets(slot).vault(c).x,planets(slot).vault(c).x+planets(slot).vault(c).w)
                        y=rnd_range(planets(slot).vault(c).y,planets(slot).vault(c).y+planets(slot).vault(c).h)
                    loop until tmap(x,y).walktru=0
                    if debug=1 then dprint "Set monster at "&x &":"&y
                    if planets(slot).vault(c).wd(6)>0 then 
                        enemy(e)=makemonster(planets(slot).vault(c).wd(6),slot)
                        enemy(e)=setmonster(enemy(d),slot,spawnmask(),lsp,vismask(),x,y,d)
                    else
                        enemy(e)=setmonster(planets(slot).mon_template(-planets(slot).vault(c).wd(6)),slot,spawnmask(),lsp,vismask(),x,y,e)
                        if debug=1 then dprint "Enemy "&e &" is at "&enemy(e).c.x &":"&enemy(e).c.y
                    endif
                next
                if debug=1 then dprint "lastenemy"&lastenemy
            endif
            
            if planets(slot).vault(c).wd(5)=3 then
                if debug=1 then dprint "lastenemy"&lastenemy
                b=rnd_range(1,4)+rnd_range(1,4)+planets(slot).depth
                d=lastenemy
                lastenemy=lastenemy+b
                for e=d to lastenemy
                    do
                        x=rnd_range(planets(slot).vault(c).x,planets(slot).vault(c).x+planets(slot).vault(c).w)
                        y=rnd_range(planets(slot).vault(c).y,planets(slot).vault(c).y+planets(slot).vault(c).h)
                    loop until tmap(x,y).walktru=0
                    if debug=1 then dprint "Set monster at "&x &":"&y
                    enemy(e)=makemonster(59,slot)
                    enemy(e)=setmonster(enemy(d),slot,spawnmask(),lsp,vismask(),x,y,e,1)
                next
                if debug=1 then dprint "lastenemy"&lastenemy
            endif
            if planets(slot).vault(c).wd(5)=4 then
                for x=planets(slot).vault(c).x to planets(slot).vault(c).x+planets(slot).vault(c).w
                    for y=planets(slot).vault(c).y to planets(slot).vault(c).y+planets(slot).vault(c).h
                        if tmap(x,y).walktru=0 then
                            lastenemy+=1
                            enemy(lastenemy)=setmonster(planets(slot).mon_template(abs(planets(slot).vault(c).wd(6))),slot,spawnmask(),lsp,vismask(),x,y,lastenemy)
                        endif    
                    next
                next
                
            endif
            planets(slot).vault(c)=del_rec
        endif
        next
    for a=1 to _NoPB
        if slot=pirateplanet(a) then
            c=5+rnd_range(1,6)
            for b=lastenemy to lastenemy+c
                enemy(b)=makemonster(3,slot)
                enemy(b)=setmonster(enemy(b),slot,spawnmask(),lsp,vismask(),,,b,1)
            next
            lastenemy=lastenemy+c
        endif
    next

endif
    
    
    
    moverover(slot,ship,li(),lastlocalitem)
    'if planets(slot).colony<>0 then growcolony(slot)
    
    if planets(slot).visited>0 and planets(slot).visited<player.turn then
        b=planets(slot).visited-player.turn
        for e=1 to lastenemy
            if enemy(e).made=101 and enemy(e).hp>0 then
                for a=1 to b
                    p=rnd_point(slot,,,1)
                    if p.x>=0 then
                        changetile(p.x,p.y,slot,4)
                        tmap(p.x,p.y)=tiles(4)
                    endif
                next
                
            endif
        next
    
    endif
    
    planets(slot).visited=player.turn    
    if planets(slot).flags(27)=1 then planets(slot).flags(27)=2
    
    if slot=specialplanet(0) and player.towed=4 then
        dprint "The alien generation ship lands next to yours and the insects start exploring and setting up their colony immediately."
        p=movepoint(ship,5)
        'questflag(0)=1
        player.towed=0
        planetmap(p.x,p.y,slot)=269
        tmap(p.x,p.y)=tiles(269)
        drifting(4).x=-1 'Move drifting off the map (Can't delete it, since then another ship could get generated there and would trigger the event
        planets(slot).mon_template(1)=makemonster(80,slot)
        planets(slot).mon_noamin(1)=10
        planets(slot).mon_noamax(1)=14
        planets(slot).mon_template(2)=makemonster(25,slot)
        planets(slot).mon_noamin(2)=10
        planets(slot).mon_noamax(2)=14
    endif
        
    
    if slot=specialplanet(1) and specialflag(1)=0 then 'apollos planet
        ship.x=rnd_range(0,60)
        ship.y=rnd_range(0,20)
    endif
    
    if slot=specialplanet(2) then
        if specialflag(2)=0 then
            specialflag(2)=1
            dprint "As you enter the lower atmosphere a powerful energy beam strikes your ship from the surface below! A planetery defense system has detected you! You are already to low to escape into orbit, so the only way to avoid total destruction is an emergency landing! Your vessel slams into the surface!",15
            player.hull=player.hull-rnd_range(1,6)
            if player.hull<=0 then
                planetmap(ship.x,ship.y,slot)=127+player.h_no
                tmap(ship.x,ship.y)=tiles(127+player.h_no)
                player.landed.m=0
            endif
            for a=0 to rnd_range(1,6)+rnd_range(1,6)
                lastenemy=lastenemy+1
                enemy(lastenemy)=makemonster(15,slot)
                enemy(lastenemy).hp=-1
            next
        endif
        if specialflag(2)=2 then
            for x=0 to 60
                for y=0 to 20
                    if planetmap(x,y,slot)=-168 then planetmap(x,y,slot)=-169
                    if planetmap(x,y,slot)=168 then planetmap(x,y,slot)=169
                    if abs(planetmap(x,y,slot))=169 then tmap(x,y)=tiles(169)
                next
            next
        endif
    endif
    
    if specialplanet(8)=slot then 'stormy,less critters
        lastenemy=lastenemy-rnd_range(1,5)
        if lastenemy<0 then lastenemy=0
    endif
    
    if specialplanet(11)=slot then lastenemy=0 'No critters on dying world
    
    if specialplanet(15)=slot then
        for a=1 to lastenemy
            for b=1 to lastenemy
            if b<>a then
                if enemy(1).lang=6 then
                    if enemy(b).lang=7 then enemy(a).flags(b)=1
                else
                    if enemy(b).lang=6 then enemy(a).flags(b)=1
                endif
            endif
            next
        next
    endif
    
    if planets(slot).flags(25)<>0 or specialplanet(40)=slot then
        for x=0 to 60
            for y=0 to 20
                tmap(x,y).disease=13
            next
        next
        if planets(slot).flags(25)=2 then 
            awayteam.helmet=1
        else
           planets(slot).mapmod=0
        endif
    endif
    '
    '   loaded game in savefrom
    '
    '    This only if savegame
    '    
    if savefrom(0).map>0 then
        awayteam=savefrom(0).awayteam
        ship=savefrom(0).ship
        slot=savefrom(0).map
        lastenemy=savefrom(0).lastenemy
        for b=1 to lastenemy
            enemy(b)=savefrom(0).enemy(b)
        next
        equip_awayteam(player,awayteam,slot)
        awayteam.oxydep=awayteam.oxydep*planets(slot).grav
        savefrom(0)=savefrom(16)
    endif        
    equip_awayteam(player,awayteam,slot)
    
    c=0
    for a=0 to lastitem
        if item(a).w.m=slot and item(a).w.s=0 then
            c=c+1
            if c<=256 then 
                li(c)=a
                if item(li(c)).ty=47 then 'Dogtag
                    lastenemy=lastenemy+1
                    enemy(lastenemy)=makemonster(15,slot)
                    enemy(lastenemy)=setmonster(enemy(lastenemy),slot,spawnmask(),lsp,vismask(),,,lastenemy,1)
                    enemy(lastenemy).hp=-1
                    enemy(lastenemy).hpmax=55
                    enemy(lastenemy).slot=16
                endif
                if slot=pirateplanet(0) and item(li(c)).w.p=0 then item(li(c)).w.p=rnd_range(1,lastenemy) 'Pirates get all the goods
            endif
        endif
    next
    if c>256 then c=256
    lastlocalitem=c
    
    lsp=0    
    for x=0 to 60
        for y=0 to 20
            mapmask(x,y)=0
            if tmap(x,y).walktru=0 then
                lsp=lsp+1
                spawnmask(lsp).x=x
                spawnmask(lsp).y=y
            endif
        next
    next
    
    if slot=specialplanet(16) then
        if findbest(24,-1)>0 then
            for a=1 to lastenemy
                enemy(a).aggr=0
            next
        else
            for a=1 to lastenemy
                enemy(a).aggr=1
            next
        endif
    endif
    
    if slot=specialplanet(37) then
        p.x=25
        p.y=5
        invisiblelabyrinth(tmap(),p.x,p.y)
    endif
    
    if alien_scanner=1 then player.stuff(3)=2
    
    'outpost trading
    for a=11 to 13
        planets(slot).flags(a)=planets(slot).flags(a)+rnd_range(1,6)+rnd_range(1,6)-rnd_range(1,6)-rnd_range(1,6)
        if planets(slot).flags(a)<0 then planets(slot).flags(a)+=1 
        if planets(slot).flags(a)>0 then planets(slot).flags(a)-=1 
        if planets(slot).flags(a)<-3 then planets(slot).flags(a)=-3
        if planets(slot).flags(a)>3 then planets(slot).flags(a)=3
        if planets(slot).flags(a)>0 then planets(slot).flags(a)-=1 
        if planets(slot).flags(a)<0 then planets(slot).flags(a)+=1 
    next
    
    if rnd_range(1,100)<33 then flag(14)=rnd_range(8,20)
    if rnd_range(1,100)<33 then planets(slot).flags(15)=1
    if rnd_range(1,100)<33 then planets(slot).flags(16)=2 
    if rnd_range(1,100)<33 then planets(slot).flags(17)=3 
    if rnd_range(1,100)<33 then planets(slot).flags(18)=4  
    if rnd_range(1,100)<33 then planets(slot).flags(19)=5 
    if rnd_range(1,100)<33 then planets(slot).flags(20)=11
    
    
    if awayteam.c.x<0 then awayteam.c.x=0
    if awayteam.c.y<0 then awayteam.c.y=0
    if awayteam.c.x>60 then awayteam.c.x=60
    if awayteam.c.y>20 then awayteam.c.y=20
    display_planetmap(slot,awayteam.c.x-_mwx/2,0)
    ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem)
    display_awayteam(awayteam, slot, lastenemy, deadcounter, ship, nightday(awayteam.c.x),localtemp(awayteam.c.x,awayteam.c.y))
    dprint ""
    '
    ' EXPLORE PLANET
    '
    
    dawn=rnd_range(1,60)
    do
        b=0
        for a=1 to lastenemy
            if enemy(a).c.x=awayteam.c.x and enemy(a).c.y=enemy(a).c.y then 
                enemy(a).c=movepoint(enemy(a).c,5)
                b=1
            endif
        next
    loop until b=0
    
    if debug=99 then dprint "Death in:" &planets(slot).death &"(in)"

    if planets_flavortext(slot)<>"" then
        dprint planets_flavortext(slot),15
        no_key=keyin
    endif
    if slot=specialplanet(1) and specialflag(1)=0 then dodialog(2,enemy(1),0)
    '***********************
    '
    'Planet Exploration Loop
    '
    '***********************
    if no_enemys=1 then lastenemy=0
    
    screenset 0,1
    color 0,0
    cls
    display_planetmap(slot,awayteam.c.x-_mwx/2,0)
    ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem)
    display_awayteam(awayteam, slot, lastenemy, deadcounter, ship,nightday(awayteam.c.x),localtemp(awayteam.c.x,awayteam.c.y))
    flip
    color 0,0
    cls
    display_planetmap(slot,awayteam.c.x-_mwx/2,0)
    ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem)
    display_awayteam(awayteam, slot, lastenemy, deadcounter, ship,nightday(awayteam.c.x),localtemp(awayteam.c.x,awayteam.c.y))
    flip
    do
        if show_all=1 then
            set__color( 15,0)
            locate 21,1
            print awayteam.disease;":";player.disease;":";planets(slot).visited;":";slot;"Temp:";localtemp(awayteam.c.x,awayteam.c.y)
        endif
        'dprint "Death"&planets(slot).death
        awayteam.dark=planets(slot).darkness+nightday(awayteam.c.x)
        if awayteam.move=4 and  player.teleportload<15 then player.teleportload+=1
        if awayteam.disease>player.disease then player.disease=awayteam.disease
        if planets(slot).atmos<=1 or planets(slot).atmos>=8 then awayteam.helmet=1
        if (tmap(awayteam.c.x,awayteam.c.y).no=1 or tmap(awayteam.c.x,awayteam.c.y).no=26 or tmap(awayteam.c.x,awayteam.c.y).no=20) and awayteam.hp<=awayteam.nohp*5 then awayteam.oxygen=awayteam.oxygen+tmap(awayteam.c.x,awayteam.c.y).oxyuse
        if tmap(awayteam.c.x,awayteam.c.y).oxyuse<0 then awayteam.oxygen=awayteam.oxygen-tmap(awayteam.c.x,awayteam.c.y).oxyuse
        if awayteam.oxygen>awayteam.oxymax then awayteam.oxygen=awayteam.oxymax
        
        if _warnings=0 and nightday(awayteam.c.x)=1 and nightday(old.x)<>1 then dprint "The sun rises"
        if _warnings=0 and nightday(awayteam.c.x)=2 and nightday(old.x)<>2 then dprint "The sun sets"
        
        old=awayteam.c
        if walking<>0 then
            if walking<0 then
                tmap(awayteam.c.x,awayteam.c.y).hp-=1
                awayteam.lastaction+=1
                displaytext(loceol.y)=displaytext(loceol.y-1) &"."
                if tmap(awayteam.c.x,awayteam.c.y).hp=1 then
                    walking=0
                    dprint "complete."   
                    key=key__i
                endif
            else
                if walking<10 then
                    awayteam.c=movepoint(awayteam.c,walking)
                endif
                if walking=12 then
                    if currapwp=lastapwp then
                        'awayteam.c=movepoint(awayteam.c,nearest(apwaypoints(currapwp),awayteam.c))
                        lastapwp=ep_autoexplore(awayteam,slot,ship,li(),lastlocalitem)
                        currapwp=0
                    endif
                    if lastapwp>0 then
                        currapwp+=1
                        'awayteam.c=movepoint(awayteam.c,nearest(apwaypoints(currapwp),awayteam.c))
                        if awayteam.move>=tmap(apwaypoints(currapwp).x,apwaypoints(currapwp).y).walktru or tmap(apwaypoints(currapwp).x,apwaypoints(currapwp).y).onopen<>0 then
                            awayteam.c=apwaypoints(currapwp)
                            awayteam.c.m=old.m
                        else
                            walking=0
                        endif
                    else
                        walking=0
                    endif

                endif
            endif
        else
            if rnd_range(1,100)<110+countdeadofficers(awayteam.hpmax) then
                awayteam.c=movepoint(awayteam.c,getdirection(key),3)
                if getdirection(key)<>0 then
                    key=""
                endif
            else
                dprint "Your security personel want to return to the ship.",14
                if rnd_range(1,100)<66 then
                    awayteam.c=movepoint(awayteam.c,nearest(ship,awayteam.c))
                else
                    awayteam.c=movepoint(awayteam.c,5)
                endif
            endif
        endif
        ep_playerhitmonster(awayteam,old,enemy(),lastenemy,vismask(),mapmask())
        ep_checkmove(awayteam,old,key)
        
        lsp=ep_updatemasks(spawnmask(),mapmask(),nightday(),dawn,dawn2)
        mapmask(awayteam.c.x,awayteam.c.y)=-9
        
        if awayteam.lastaction>0 then 
            awayteam.lastaction-=1
            if awayteam.lastaction<0 then awayteam.lastaction=0
            localturn=localturn+1
            awayteam.oxygen=awayteam.oxygen-maximum(awayteam.oxydep*awayteam.helmet,tmap(awayteam.c.x,awayteam.c.y).oxyuse)
            if awayteam.oxygen<0 then dprint "Asphyixaction:"&damawayteam(awayteam,rnd_range(1,awayteam.hp),1),12
            ep_tileeffects(awayteam,areaeffect(),last_ae,lavapoint(),nightday(),localtemp(),cloudmap(),vismask())
            ep_shipfire(shipfire(),vismask(),enemy(),lastenemy,awayteam)
            ep_items(awayteam,li(),lastlocalitem,enemy(),lastenemy,localturn,vismask(),ship)
            walking=alerts(awayteam)
            for a=1 to lastenemy
                if enemy(a).hp>0 then m(a)=m(a)+enemy(a).move
            next
            deadcounter=ep_monstermove(awayteam,enemy(),m(),lastenemy,li(),lastlocalitem,spawnmask(),lsp,vismask(),mapmask(),nightday())
            if player.dead>0 or awayteam.hp<=0 then 
                allowed=""
                awayteam.lastaction=1
            endif
        endif
            
        if old.x<>awayteam.c.x or old.y<>awayteam.c.y or key=key_portal or key=key__i then nextmap=ep_Portal(awayteam)
        
        if ship_landing>0 and nextmap.m<>0 then ship_landing=1 'Lands immediately if you changed maps
        if ship_landing>0 then ep_landship(ship_landing, nextlanding, ship, nextmap, vismask(), enemy(),lastenemy)
        
        if  tmap(awayteam.c.x,awayteam.c.y).resources>0 or planetmap(awayteam.c.x,awayteam.c.y,slot)=17 or  (tmap(awayteam.c.x,awayteam.c.y).no>2 and tmap(awayteam.c.x,awayteam.c.y).gives>0 and player.dead=0 and (awayteam.c.x<>old.x or awayteam.c.y<>old.y))  then
            old=awayteam.c
            screenset 1,0
            cls
            display_planetmap(slot,awayteam.c.x-_mwx/2,0)
            ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem)
            ep_display_clouds(awayteam,cloudmap(),vismask())
            display_awayteam(awayteam, slot, lastenemy, deadcounter, ship,nightday(awayteam.c.x),localtemp(awayteam.c.x,awayteam.c.y))
            screenset 0,1
            cls
            display_planetmap(slot,awayteam.c.x-_mwx/2,0)
            ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem)
            display_awayteam(awayteam, slot, lastenemy, deadcounter, ship,nightday(awayteam.c.x),localtemp(awayteam.c.x,awayteam.c.y))
            ep_display_clouds(awayteam,cloudmap(),vismask())
            
            dprint("")
            ep_gives(awayteam,vismask(),nextmap,shipfire(),enemy(),lastenemy,li(),lastlocalitem,spawnmask(),lsp,key,ship,localtemp(awayteam.c.x,awayteam.c.y))
            equip_awayteam(player,awayteam,slot)
            if awayteam.move=2 or awayteam.move=3 then allowed=allowed &key_ju
            if awayteam.move=4 then allowed=allowed &key_te
            'displayplanetmap(slot,awayteam.c.x-_mwx/2)
            'ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem,walking)
            'displayawayteam(awayteam, slot, lastenemy, deadcounter, ship,nightday(awayteam.c.x))
            dprint("")
            walking=0
        endif
        
        ep_planeteffect(awayteam,ship,enemy(),lastenemy,li(),lastlocalitem,shipfire(),sf,lavapoint(),vismask(),localturn,cloudmap())
        ep_areaeffects(awayteam,areaeffect(),last_ae,lavapoint(),enemy(),lastenemy,li(),lastlocalitem,cloudmap())
        walking=ep_atship(awayteam,ship)
        if old.x<>awayteam.c.x or old.y<>awayteam.c.y or key=key_pickup then ep_pickupitem(key,awayteam,lastlocalitem,li(),enemy(),lastenemy)
        if key=key__i or _autoinspect=0 and (old.x<>awayteam.c.x or old.y<>awayteam.c.y) then ep_inspect(awayteam,ship,enemy(),lastenemy,li(),lastlocalitem,localturn)
        healawayteam(awayteam,0)
        key=""
        if (player.dead=0 and awayteam.lastaction<=0) or walking<>0 then 
            'Display all stuff
            screenset 1,0
            cls
            
            
            
            display_planetmap(slot,awayteam.c.x-_mwx/2,0)
            ep_display (awayteam,vismask(),enemy(),lastenemy,li(),lastlocalitem)
            ep_display_clouds(awayteam,cloudmap(),vismask())
            display_awayteam(awayteam, slot, lastenemy, deadcounter, ship,nightday(awayteam.c.x),localtemp(awayteam.c.x,awayteam.c.y))
            
            comstr=key_ex &" examine;" &key_fi &" fire,"&key_autofire &" autofire;" &key_autoexplore &" autoexplore;"
            comstr=comstr & key_gr &" grenade;" &key_oxy &" open/close helmet;" &key_close &" close door;" &key_drop &" Drop;"
            comstr=comstr & key_he &" use medpack;" &key_report &" bioreport;"&key_ra &" radio;"
            if awayteam.move=2 or awayteam.move=3 then comstr=comstr &key_ju &" Jetpackjump;"
            if awayteam.move=4 then comstr=comstr &key_te &" Teleport;"
    
            set__color( 11,0)
            osx=calcosx(awayteam.c.x,planets(slot).depth)
            for x=0 to 60
                if x-osx>=0 and x-osx<=_mwx and nightday(x)=1 then draw_string((x-osx)*_fw1,21*_fh1+(_fh1-_fh2)/2-_fh2/2,chr(193),Font2,_tcol)
                if x-osx>=0 and x-osx<=_mwx and nightday(x)=2 then draw_string((x-osx)*_fw1,21*_fh1+(_fh1-_fh2)/2-_fh1/2,chr(193),Font2,_tcol)
            next
            dprint ""
            flip
            screenset 1,1
            
            if nextmap.m=0 then key=(keyin(allowed,walking))
            if rnd_range(1,100)<disease(awayteam.disease).nac then 
                key=""
                dprint "ZZZZZZZZZZZzzzzzzzz",14
                awayteam.lastaction+=2
            endif         
        else
            if player.dead<>0 then allowed=""
        endif
        
        if key<>"" then walking=0
        if rnd_range(1,100)<tmap(awayteam.c.x,awayteam.c.y).disease*2-awayteam.helmet*3 then infect(rnd_range(1,awayteam.hpmax),tmap(awayteam.c.x,awayteam.c.y).disease)
        'dprint "mouse.s"&mouse.s
        if key=key_ex  then ep_examine(awayteam,ship,vismask(),li(),enemy(),lastenemy,lastlocalitem)
        if key=key_save then
            if askyn("Do you really want to save the game (y/n?)") then
               savefrom(0).map=slot
               savefrom(0).ship=ship
               savefrom(0).awayteam=awayteam
               savefrom(0).lastenemy=lastenemy
               for a=1 to lastenemy
                   savefrom(0).enemy(a)=enemy(a)
               next
               savefrom(0).lastlocalitem=lastlocalitem
               player.dead=savegame()   
               'ship.x=-1
            endif
        endif
        if key=key_wait then awayteam.lastaction+=1
        'dprint awayteam.lastaction &""
        if awayteam.lastaction<=0 then
            'if old.x<>awayteam.c.x or old.y<>awayteam.c.y or key=key_pickup then ep_pickupitem(key,awayteam,lastlocalitem,li())
            if key=key_drop then ep_dropitem(awayteam,li(),lastlocalitem,enemy(),lastenemy,vismask())
            if key=key_awayteam then showteam(1)
            if key=key_report then bioreport(slot)
            if key=key_close then ep_closedoor(awayteam)
            if key=key_gr then ep_grenade(awayteam,shipfire(),sf,li(),lastlocalitem)
            if key=key_fi or key=key_autofire or walking=10 then ep_fire(awayteam,enemy(),lastenemy,vismask(),mapmask(),key,autofire_target)
            if key=key_ra then ep_radio(awayteam,ship,nextlanding,ship_landing,li(),lastlocalitem,enemy(),lastenemy,shipfire(),lavapoint(),sf)
            if key=key_oxy then ep_helmet(awayteam)
            if key=key_ju and awayteam.move>=2 then ep_jumppackjump(awayteam)
            if key=key_la then ep_launch(awayteam,ship,nextmap)
            if key=key_he then
                if awayteam.disease>0 then
                    cureawayteam(0)
                else
                    if _chosebest=0 then
                        c=findbest(11,-1)
                    else 
                        c=getitem(-1,11)
                    endif 
                    if c>0 then
                        if item(c).ty<>11 then
                            dprint "you can't use that."
                        else
                            if askyn("Do you want to use the "&item(c).desig &"(y/n)?") then
                                item(c).v1=healawayteam(awayteam,item(c).v1)
                                if item(c).v1<=0 then destroyitem(c)
                            endif
                        endif
                    else
                        dprint "you dont have any medpacks"
                    endif
                endif
            endif
            if key=key_walk or key=key_autoexplore then 
                if key<>key_autoexplore then
                    dprint "Direction? (0 for autoexplore)"
                    no_key=keyin
                    walking=getdirection(no_key)
                else
                    no_key="0"
                endif
                if no_key="0" then 
                    lastapwp=ep_autoexplore(awayteam,slot,ship,li(),lastlocalitem)
                    currapwp=0
                    if lastapwp>-1 then 
                        walking=12
                    else
                        dprint "All explored here."
                    endif
                endif
            endif
            if key=key_co or key=key_of then ep_communicateoffer(key,awayteam,enemy(),lastenemy,li(),lastlocalitem)
            if key=key_te and awayteam.move=4 then awayteam.c=teleport(awayteam.c,slot) 
            if key="�" then
                for x=0 to 60
                    for y=0 to 20
                        planetmap(x,y,slot)=abs(planetmap(x,y,slot))
                    next
                next
                for a=0 to lastportal
                    if portal(a).from.m=slot then portal(a).discovered=1
                    if portal(a).dest.m=slot then portal(a).discovered=1
                next
                for a=0 to lastlocalitem
                    item(li(a)).discovered=1
                next
            endif
            com_sinkheat(player,0)
            ep_lava(awayteam,lavapoint(),ship,vismask())
            lastenemy=ep_spawning(enemy(),lastenemy,spawnmask(),lsp,diesize,vismask())
        endif
        
        
        
        if lastenemy>255 then lastenemy=255
        if lastlocalitem>255 then lastlocalitem=255
        
        'clean up item list
        for a=1 to lastlocalitem
            if item(li(a)).w.s<0 then
                li(a)=li(lastlocalitem)
                lastlocalitem=lastlocalitem-1
            else 
                if tmap(item(li(a)).w.x,item(li(a)).w.y).no>=175 and tmap(item(li(a)).w.x,item(li(a)).w.y).no<=177 then 
                    destroyitem(li(a))
                    li(a)=li(lastlocalitem)
                    lastlocalitem=lastlocalitem-1
                endif
            endif
        next
        if debug=99 then dprint "Death in:"&planets(slot).death
        ' and the world moves on
        if frac(localturn/10)=0 then
            player.turn=player.turn+1
            for a=1 to lastplanet
                if planets(a).flags(27)=2 then 
                    planets(a).death-=1 
                    if a=slot and planets(a).death<=0 then 
                        if planets(a).flags(29)=0 then 
                            player.dead=17
                        else
                            player.dead=34
                        endif
                    endif
                endif
            next
            for a=0 to laststar
                if map(a).planets(1)>0 then
                    if planets(map(a).planets(1)).flags(27)=2 and planets(map(a).planets(1)).death<=0 then 
                        map(a).planets(1)=0
                    endif
                endif
            next

            diseaserun(1)    
            equip_awayteam(player,awayteam,slot)
            move_fleets()
            if frac(player.turn/250)=0 then rerollshops 
        endif
        
        
    loop until awayteam.hp<=0 or nextmap.m<>0 or player.dead<>0
    
    '
    ' END exploring
    
    for a=0 to lastlocalitem
        if item(li(a)).ty=45 and item(li(a)).w.p<9999 and item(li(a)).w.s=0 then 'Alien bomb
            if item(li(a)).v2=1 then
                p1.x=item(li(a)).w.x
                p1.y=item(li(a)).w.y
                item(li(a)).w.p=9999
                alienbomb(awayteam,li(a),slot,enemy(),lastenemy,li(),lastlocalitem)

            endif
        endif
    next
    
    for a=0 to lastitem
        if item(a).w.p=9999 then 
            item(a)=item(lastitem)
            lastitem=lastitem-1
        endif
    next
    
    b=0
    for a=1 to lastenemy
        if enemy(a).hp>0 then b=b+1
    next
    if b=0 then planets(slot).genozide=1

    if awayteam.hp<=0 then 
        reward(2)=0
        reward(1)=0
        if player.dead=0 then player.dead=3
        
        for a=1 to lastdrifting
            if slot=drifting(a).m then player.dead=25
        next
        player.landed.s=planets(slot).depth
        if player.dead=25 then player.landed.s=slot
        dprint "The awayteam has been destroyed.",12
        if slot=specialplanet(0) then player.dead=8
        if slot=specialplanet(1) then player.dead=9
        if slot=specialplanet(3) or slot=specialplanet(4) then player.dead=10
        if slot=specialplanet(5) then player.dead=11
        if awayteam.oxygen<1 then player.dead=14
        no_key=keyin
    endif
    
    if player.dead<>0 then
        player.c=awayteam.c
        savebones(ship,awayteam.c,1) 'On planet
    endif
    
    if player.dead=0 and planets(slot).atmos>0 and planets(slot).depth=0 and planets(slot).atmos=player.questflag(10) then 
        a=0
        for x=0 to 60
            for y=0 to 20
                a=a+tmap(x,y).vege
                if planetmap(x,y,slot)>0 then b+=1
            next
        next
        if a=0 then
            dprint "This planet would suit Omega Bioengineerings Requirements."
            player.questflag(10)=-slot
        endif
    endif
    
    if planets(slot).depth=0 and planets(slot).flags(21)=0 then
        a=0
        for x=0 to 60
            for y=0 to 20
                if planetmap(x,y,slot)>0 then a+=1
            next 
        next
        if a>=1199 then 
            planets(slot).flags(21)=1
            dprint "You have completely mapped this planet.",10
        endif
    endif
    
    if specialplanet(10)=slot then
        for x=0 to 60
            for y=0 to 20
                if planetmap(x,y,slot)=-60 then planetmap(x,y,slot)=-4
                if planetmap(x,y,slot)=60 then planetmap(x,y,slot)=4
            next
        next
    endif
    
    if specialplanet(17)=slot then
        a=1
        for x=0 to 60
            for y=0 to 20
                if abs(planetmap(x,y,slot))=107 then a=0
            next
        next
        specialflag(17)=a
    endif
    
    if slot=pirateplanet(0) and planets(slot).genozide=1 then
        dprint "Congratulations! You have destroyed the pirates base!",10
        reward(6)=50000
        piratebase(0)=-1
        pirateplanet(0)=-1
        no_key=keyin
    endif    
    if slot=pirateplanet(0) and awayteam.hp<=0 then player.dead=7
    c=0
    for a=1 to _NoPB
        if slot=pirateplanet(a) then
            for b=1 to lastenemy
                if enemy(b).hp>0 then
                    if enemy(b).made=7 or enemy(b).made=3 then c=c+1
                endif
            next
            if c=0 and awayteam.hp>0 then
                reward(8)=reward(8)+10000
                piratebase(a)=-1
                pirateplanet(a)=-1
            endif
        endif
    next
    
    b=0
    for a=1 to 15
        if slot=savefrom(a).map then b=a
    next
    if b=0 then
        for a=15 to 1 step -1
            if savefrom(a).map=0 then b=a
        next
    endif
    if b=0 then
        for a=1 to 14
            savefrom(a)=savefrom(a+1)
        next
        savefrom(15)=savefrom(16) '16 bleibt immer leer
        b=15
    endif
    a=b
    if lastenemy>129 then lastenemy=129
    savefrom(a).lastenemy=lastenemy
    savefrom(a).map=slot
    for b=1 to lastenemy
        savefrom(a).enemy(b)=enemy(b)
    next
    'if slot=specialplanet(12) and player.dead<>0 then player.dead=17
    if player.dead<>0 then screenshot(3)
    return nextmap
end function

function alienbomb(awayteam as _monster,c as short,slot as short, enemy() as _monster,lastenemy as short, li() as short, byref lastlocalitem as short) as short
    dim as short a,b,d,e,f,osx
    dim as _cords p,p1 
    p1.x=item(c).w.x
    p1.y=item(c).w.y
    osx=calcosx(awayteam.c.x,planets(slot).depth)
                                        
    for e=0 to item(c).v1*6
        
        for x=0 to 60
            for y=0 to 20
                p.x=x
                p.y=y
                f=int(distance(p,p1))
                set__color( 0,0)
                if f=e  then set__color( 0,1)
                if f=e+7 then set__color( 236,15)
                if f=e+6 then set__color( 236,237)
                if f=e+5 then set__color( 237,238)
                if f=e+4 then set__color( 238,239)
                if f=e+3 then set__color( 239,240)
                if f=e+2 then set__color( 240,241)
                if f=e+1 then set__color( 241,1)
                if f=e-1 then set__color( 0,0)
                if f=e-2 then set__color( 0,0)
                if f>=e-2 and f<=e+7 then
                    if _tiles=0 then
                        if x-osx>=0 and x-osx<=_mwx then put ((x-osx)*_tix,y*_tiy),gtiles(gt_no(76+f-e)),pset
                    else
                        draw string(x*_fw1,y*_fh1), chr(176),,font1,custom,@_col
                    endif
                endif
                if f<e then
                    if tmap(x,y).shootable>0 then
                        d=rnd_range(1,item(c).v1*12)
                        if tmap(p.x,p.y).dr<d then
                            tmap(p.x,p.y).hp=tmap(p.x,p.y).hp-d
                        else
                            tmap(p.x,p.y).dr=tmap(p.x,p.y).dr-d
                        endif
                        if tmap(x,y).hp<=0 then 
                            if planetmap(x,y,slot)>0 then planetmap(x,y,slot)=tmap(x,y).turnsinto
                            if planetmap(x,y,slot)<0 then planetmap(x,y,slot)=-tmap(x,y).turnsinto
                            tmap(x,y)=tiles(tmap(x,y).turnsinto)
                        endif
                    endif
                endif
            next
        next
        sleep 50
    next
    
    for e=242 to 249
        for x=0 to 60
            for y=0 to 20
                set__color( e,e)
                if _tiles=0 then
                    if x-osx>=0 and x-osx<=_mwx then put ((x-osx)*_tix,y*_tiy),gtiles(gt_no(rnd_range(63,66))),pset
                else
                    draw_string(x*_fw1,y*_fh1, chr(176),font1,_col)
                endif
            next
        next
        sleep 50
    next
    
    for e=0 to lastenemy
        if distance(enemy(e).c,p1)<item(c).v1*5 then enemy(e).hp=enemy(e).hp-item(c).v1*3
    next
    for e=0 to item(c).v1
        if planets(slot).atmos>1 and item(c).v1>1 then
            planets(slot).atmos-=1
            item(c).v1-=2
            if planets(slot).atmos=6 or planets(slot).atmos=12 then planets(slot).atmos=1
        endif
    next
    for a=0 to lastlocalitem
        p.x=item(li(a)).w.x
        p.y=item(li(a)).w.y
        if a=c or (rnd_range(1,100)+item(c).v1>item(li(a)).res and distance(p,p1)<item(c).v1*5) then
            destroyitem(li(a))
            li(a)=li(lastlocalitem)
            lastlocalitem-=1
        endif
    next
    display_planetmap(slot,awayteam.c.x-_mwx/2,0)          
                                
    
    return 0
end function


function grenade(from as _cords,map as short) as _cords
    dim as _cords target,ntarget
    dim as single dx,dy,x,y,launcher
    dim as short a,ex,r,t,osx
    dim as string key
    dim p as _cords
    
    dim as short local_debug=0 
    osx=from.x-_mwx/2
    if osx<0 then osx=0
    if osx>=60-_mwx then osx=60-_mwx
    
    target.x=from.x
    target.y=from.y
    ntarget.x=from.x
    ntarget.y=from.y
    x=from.x
    y=from.y
    p=from
    ntarget=from
    launcher=findbest(17,-2)
    if local_debug=1 then dprint ""&launcher
    if launcher>0 then
        dprint "Choose target"
        do 
            ntarget=target
            key=cursor(ntarget,map,osx)
            if distance(ntarget,from)<5+item(launcher).v1-planets(map).grav then
                target.x=ntarget.x
                target.y=ntarget.y
            endif
            if key=key_te or ucase(key)=" " or multikey(SC_ENTER) then ex=-1
            if key=key_quit or multikey(SC_ESCAPE) then ex=1    
        loop until ex<>0
        r=distance(from,target)
        dx=(target.x-from.x)/r
        dy=(target.y-from.y)/r
    else
        dprint "Choose direction"
        key=keyin("12346789"&" "&key__esc)
        if getdirection(key)=0 then
            ex=1
        else
            r=3-planets(map).grav
            if getdirection(key)=1 then
                dx=-.7
                dy=.7
            endif
            if getdirection(key)=2 then
                dx=0
                dy=1
            endif
            if getdirection(key)=3 then
                dx=.7
                dy=.7
            endif
            if getdirection(key)=4 then
                dx=-1
                dy=0
            endif
            if getdirection(key)=6 then
                dx=1
                dy=0
            endif
            if getdirection(key)=7 then
                dx=-.7
                dy=-.7
            endif
            if getdirection(key)=8 then
                dx=0
                dy=-1
            endif
            if getdirection(key)=9 then
                dx=.7
                dy=-.7
            endif
        endif
    endif
    if ex=1 then
        target.x=-1
        target.y=-1
    else
        for a=1 to r
            x=x+dx
            y=y+dy
            t=abs(planetmap(x,y,map))
            if tiles(t).firetru=1 then exit for
        next
        if x<0 then x=0
        if y<0 then y=0
        if x>60 then x=60
        if y>20 then y=20
        target.x=x
        target.y=y
    endif
    if local_debug=1 then dprint ""&target.x &":"& target.y
    return target    
end function

function teleport(from as _cords,map as short) as _cords
    dim target as _cords
    dim ntarget as _cords
    dim otarget as _cords
    dim ex as short
    dim key as string
    dim osx as short
    osx=from.x-_mwx/2
    if osx<0 then osx=0
    if osx>=60-_mwx then osx=60-_mwx
    
    if planets(map).teleport<>0 then
        dprint "Something is jamming your teleportation device!",14
        return from
    endif
    target.x=from.x
    target.y=from.y
    ntarget=target
    do 
        key=cursor(ntarget,map,osx)
        if distance(ntarget,from)<10 then
            target.x=ntarget.x
            target.y=ntarget.y
        endif
        if key=key_te or ucase(key)=" " or multikey(SC_ENTER) then ex=1
        if key=key_quit or multikey(SC_ESCAPE) then ex=-1    
    loop until ex<>0
    if ex=1 then
        if player.teleportload>=10 then 
            from.x=target.x
            from.y=target.y
            player.teleportload=0
        else
            dprint "The teleportation device still needs some time to recharge"
        endif
    endif
    return from
end function

function wormhole_ani(target as _cords) as short
    dim p(sm_x*sm_y) as _cords
    dim as short last,a,c
    last=Line_in_points(target,player.c,p())
    for a=1 to last-1
        set__color( rnd_range(180,214),rnd_range(170,204))
        if p(a).x-player.osx>=0 and p(a).x-player.osx<=_mwx and p(a).y-player.osy>=0 and p(a).y-player.osy<=20 then
            if _tiles=0 then
                put ((p(a).x-player.osx)*_fw1,(p(a).y-player.osy)*_fh1),stiles(player.di,player.ti_no),trans
            else
                draw_string((p(a).x-player.osx)*_fw1,(p(a).y-player.osy)*_fh1,"@",font1,_col)
            endif
            player.di+=1
            if player.di=5 then player.di=6
            if player.di>9 then player.di=1 
            sleep 50
            for c=0 to laststar+wormhole
                if map(c).discovered>0 then display_star(c,0)
            next
        else
            cls
            display_ship(1)
            show_stars(1)
            dprint ""
        endif
    next
    player.c=p(last-1)
    return 0
end function

function scan_all() as short
    
    return 0
end function


function space_radio() as short
    dim as short i,closestfleet,closestdrifter,lc,j
    dim as _cords p
    dim dummy as _monster
    dim du(2) as short
    dim debug as short
    dim contacts(25) as short
    dim as string fname(8),text
     
    gen_fname(fname())
    
    dim as single df,dd
    df=9999
    for i=1 to lastfleet
        if fleet(i).ty=1 or fleet(i).ty=3 or fleet(i).ty=6 or fleet(i).ty=7 then
            if distance(fleet(i).c,player.c)<player.sensors*2 then
                lc+=1
                contacts(lc)=i
            endif
        endif
    next
    dd=9999
    for i=1 to lastdrifting
        p.x=drifting(i).x
        p.y=drifting(i).y
        if i<=3 or (planets(drifting(i).m).mon_template(0).made=32 and planets(drifting(i).m).flags(0)=0) then
            if distance(p,player.c)<player.sensors*2 then
                lc+=1
                contacts(lc)=-i 'Drifters are negative
            endif
        endif
    next
    dprint lc &"=LC"
    if lc>0 then
        if lc=1 then
            i=contacts(lc)
        else
            text="Contact:"
            for j=1 to lc
                if contacts(j)>0 then 
                    text=text &"/"&fname(fleet(contacts(j)).ty)
                else
                    text=text &"/"&shiptypes(drifting(abs(contacts(j))).s)
                endif
            next
            i=menu(text,"",0,20-lc)
            if i<0 then return 0
            i=contacts(i)
        endif
    else
        i=0
        dprint "No contact."
    end if
    dprint "I="&i
    select case i
    case is>0
        if fleet(i).ty=1 and i>5 then dodialog(5,dummy,i)
        if fleet(i).ty=3 then dodialog(3,dummy,i)
        dummy.lang=fleet(i).ty+26
        dummy.aggr=1
        if debug=2 then dprint ""&dummy.lang
        if fleet(i).ty=6 then communicate(dummy,dummy,1,du(),1,1)
        if fleet(i).ty=7 then communicate(dummy,dummy,1,du(),1,1)
        
    case is<0
        i=abs(i)
        if i<=3 then 
            dodialog(10,dummy,-i)
            return 0
        endif
        p.x=drifting(i).x
        p.y=drifting(i).y
        if planets(drifting(i).m).mon_template(0).made=32 and planets(drifting(i).m).flags(0)=0 then 
            dodialog(4,dummy,-i)
        else
            dprint "They don't answer."
        
        endif
        
    end select
    return 0
end function


function launch_probe() as short
    dim as short i
    i=getitem(-1,55)
    if i>0 then
        show_stars(1)
        display_ship(1)
        dprint "Which direction?"
        lastprobe+=1
        if lastprobe>100 then lastprobe=1
        probe(lastprobe).x=player.c.x
        probe(lastprobe).y=player.c.y
        probe(lastprobe).m=i
        probe(lastprobe).s=getdirection(keyin())
        probe(lastprobe).p=item(i).v4
        dprint probe(lastprobe).x &":"&probe(lastprobe).y
        dprint "Probe Launched"
        item(i).w.s=0
    endif
    return 0
end function

function move_probes() as short
    dim as short i,x,y,j,navcom,t,d
    
    if lastprobe>0 then
    navcom=findbest(52,-1)
    for i=1 to lastprobe
        
        if probe(i).m>0 then
            probe(i).z-=item(probe(i).m).v5
            if probe(i).z<=0 then
            probe(i).z+=10
            for j=laststar+1 to laststar+wormhole
                if map(j).c.x=probe(i).x and map(j).c.y=probe(i).y then 
                    map(j).discovered=1
                    if askyn("Do you want to direct the probe into the wormhole?(y/n)") then
                        if rnd_range(1,6)+rnd_range(1,6)<9 then
                            t=map(j).planets(1)
                            d=distance(map(t).c,probe(i))
                            probe(i).x=map(t).c.x
                            probe(i).y=map(t).c.y
                            dprint "The probe traveled " &d &" parsecs to "&map(t).c.x &":"&map(t).c.y &"."
                            exit for
                        else
                            item(probe(i).m).v1=0
                        endif
                    endif
                endif
            next
            
            probe(i)=movepoint(probe(i),probe(i).s,,1)
            item(probe(i).m).v1-=1
            for x=probe(i).x-1 to probe(i).x+1
                for y=probe(i).y-1 to probe(i).y+1
                    if x>=0 and y>=0 and x<=sm_x and y<=sm_y then
                        if abs(spacemap(x,y))<6 then
                            spacemap(x,y)=abs(spacemap(x,y))
                            if spacemap(x,y)=0 and navcom>0 then spacemap(x,y)=1
                        endif
                        for j=1 to laststar
                            if map(j).c.x=x and map(j).c.y=y and map(j).spec<8 then map(j).discovered=1
                            if map(j).c.x=probe(i).x and map(j).c.y=probe(i).y then map(j).discovered=1
                        next
                    endif
                next
            next
            if abs(spacemap(probe(i).x,probe(i).y))>=6 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>9 then
                spacemap(x,y)=abs(spacemap(x,y))
            endif

            for j=1 to lastdrifting
                if drifting(j).x=probe(i).x and drifting(j).y=probe(i).y then drifting(j).p=1
            next
            if spacemap(probe(i).x,probe(i).y)>1 then
                if rnd_range(1,6)+rnd_range(1,6)+item(probe(i).m).v2<10 then
                    item(probe(i).m).v3-=1
                endif
            endif
        endif
        endif
    next
        for i=1 to lastprobe
            if item(probe(i).m).v1<=0 or item(probe(i).m).v2<=0 then
                dprint "Lost contact with probe at "&probe(i).x &":"&probe(i).y &".",14
                probe(i)=probe(lastprobe)
                lastprobe-=1
            endif
        next
    endif
    return 0
end function


function planetflags_toship(m as short) as _ship
    dim s as _ship
    dim as short f,e
    e=0
    for f=6 to 10 
        if planets(m).flags(f)>0 then
            e=e+1
            s.weapons(e)=makeweapon(planets(m).flags(f))
        endif
        if planets(m).flags(f)=-1 then
            e=e+1
            s.weapons(e)=makeweapon(99)
        endif
        if planets(m).flags(f)=-2 then
            e=e+1
            s.weapons(e)=makeweapon(98)
        endif
        if planets(m).flags(f)=-3 then
            e=e+1
            s.weapons(e)=makeweapon(97)
        endif
    next
    return s
end function


function poolandtransferweapons(s1 as _ship,s2 as _ship) as short
    dim as short e,f,c,g,d,x,y,bg
    dim as string text,help,desc,key
    dim as _cords crs,h1,h2
    dim weapons(1,10) as _weap
    e=0
    ' old weapons
    for f=1 to 5
        if s1.weapons(f).desig<>"" then
            e=e+1
            weapons(0,e)=s1.weapons(f)
            s1.weapons(f)=makeweapon(0)
        else
            if f<=s1.h_maxweaponslot then weapons(0,f).desig="-empty-"
        endif
    next
    'new weapons
    e=0
    for f=1 to 5
        if s2.weapons(f).desig<>"" then
            e=e+1
            weapons(1,e)=s2.weapons(f)
            s2.weapons(f)=makeweapon(0)
        else
            if f<=s2.h_maxweaponslot then weapons(1,f).desig="-empty-"
        endif
    next
    do
    cls
        set__color( 15,0)
        draw_string(0,0,"New Ship",font2,_col)
        draw_string(35*_fw2,0,"Old Ship",font2,_col)
        for x=0 to 1
            for y=1 to 5
                bg=0
                if h1.x=x and h1.y=y then bg=5
                if h2.x=x and h2.y=y then bg=5
                if crs.x=x and crs.y=y then bg=11
                set__color( 15,bg)
                draw_string(x*35*_fw2,y*_fh2,trim(weapons(x,y).desig)&" ",font2,_col)
            next
        next
        set__color( 15,0)
        draw_string(5*_fw2,6*_fh2,"x to swap, esc to exit",font2,_col)
        if weapons(crs.x,crs.y).desig<>"-empty-" then
            help =weapons(crs.x,crs.y).desig & " | | Damage: "&weapons(crs.x,crs.y).dam &" | Range: "&weapons(crs.x,crs.y).range &"\"&weapons(crs.x,crs.y).range*2 &"\" &weapons(crs.x,crs.y).range*3 
        else
            help = "Empty slot"
        endif
        textbox(help,2,8,25,11,1)
        set__color( 15,0)
        key=keyin()
        crs=movepoint(crs,getdirection(key))
        if crs.x<0 then crs.x=1
        if crs.x>1 then crs.x=0
        if crs.y<1 then crs.y=5
        if crs.y>5 then crs.y=1
        if crs.x=0 and crs.y>player.h_maxweaponslot+1 then crs.y=1
        if crs.x=1 and crs.y>s1.h_maxweaponslot+1 then crs.y=1
        if key=key__enter then
            if crs.x=0 then 
                h1=crs
                if crs.y<1 then crs.y=5
                if crs.y>5 then crs.y=1
                if crs.y>s2.h_maxweaponslot then crs.y=s2.h_maxweaponslot
            endif
            if crs.x=1 then 
                h2=crs
                if crs.y<1 then crs.y=5
                if crs.y>5 then crs.y=1
                if crs.y>s1.h_maxweaponslot then crs.y=s1.h_maxweaponslot
            endif
        endif
        if key="x" and h1.y<>0 and h2.y<>0 then 
            swap weapons(h1.x,h1.y),weapons(h2.x,h2.y)
        endif
    loop until key=key__esc
    for f=1 to player.h_maxweaponslot
        if weapons(0,f).desig<>"-empty-" then player.weapons(f)=weapons(0,f)
    next
    recalcshipsbays()
    return 0
end function
                        

function movemonster(enemy as _monster, ac as _cords, mapmask() as byte,tmap() as _tile) as _monster
    dim direction as short
    dim dir2 as short
    dim p1 as _cords
    dim sp1 as _cords
    dim sp2 as _cords
    dim sp3 as _cords
    dim pa as _cords
    dim p(4) as _cords
    dim a as short
    dim ti as short
   
    enemy.nearest=0
    p1.x=enemy.c.x
    p1.y=enemy.c.y
    'mapmask(ac.x,ac.y)=-9
    
    if enemy.aggr=0 or enemy.aggr=1 then
        direction=nearest(ac,p1,1)
    endif
    
    if enemy.aggr=2 then
        direction=nearest(p1,ac,1)
    endif

   
    '
    ' wirf ne m�nze mach ne kurve
    '

    
    if enemy.c.y<2 and direction=8 and enemy.aggr<>0  then
        if rnd_range(1,100)<51 then
            direction=7
        else 
            direction=9
        endif
    endif
    
    if enemy.c.y>18 and direction=2 and enemy.aggr<>0  then
        if rnd_range(1,100)<51 then
            direction=1
        else 
            direction=3
        endif
    endif
    
    p(2)=movepoint(p1,bestaltdir(direction,1),3)
    p(3)=movepoint(p1,bestaltdir(direction,0),3)
    p(4)=movepoint(p1,direction,3)
    
    for a=2 to 4
        ti=tmap(p(a).x,p(a).y).walktru
        
        if mapmask(p(a).x,p(a).y)>0 then
            enemy.nearest=mapmask(p(a).x,p(a).y)
            p(a).x=-1
            p(a).y=-1
        endif
        
        if (ti>0 and enemy.stuff(ti)=0) then
            p(a).x=-1
            p(a).y=-1
        endif
    next
    if p(2).x>=0 and p(2).y>=0 then dir2=bestaltdir(direction,1)
    if p(3).x>=0 and p(3).y>=0 then dir2=bestaltdir(direction,0)
    if p(4).x>=0 and p(4).y>=0 then dir2=direction
    p1.x=enemy.c.x
    p1.y=enemy.c.y
    
    if dir2>0 then enemy.c=movepoint(enemy.c,dir2)
    if mapmask(enemy.c.x,enemy.c.y)=-9 then
        enemy.c.x=p1.x
        enemy.c.y=p1.y
    endif
    return enemy
end function

function monsterhit(attacker as _monster, defender as _monster) as _monster
    dim mname as string
    dim text as string
    dim a as short
    dim b as short
    dim noa as short
    dim col as short
    dim as short local_debug
    if attacker.stuff(1)=1 and attacker.stuff(2)=1 then mname="flying "
    mname=mname & attacker.sdesc    
    text="The "
    if distance(attacker.c,defender.c)<1.5 then
        text=text &mname &" attacks :"
    else
        text=text &mname &" "&attacker.swhat &":"
        col=14
    endif
    noa=attacker.hp\7
    if noa<1 then noa=1
    for a=1 to noa
        if rnd_range(1,20)-defender.armor\(6*(defender.hp+1))+attacker.weapon>13+defender.move*5 then b=b+1+attacker.weapon
    next
    if b>attacker.weapon+5+noa/2 then b=attacker.weapon+5+noa/2 'max damage    
    if defender.made=0 then 
        if b>0 then
            text=text & damawayteam(defender,b,,attacker.disease)
            col=12
        else
            text=text & " no casualties."
            col=10
        endif
        if defender.hp<=0 then player.killedby=attacker.sdesc
        dprint text,col 
    else
        defender.hp=defender.hp-b 'Monster attacks monster
        if defender.hp<=0 then defender.killedby=attacker.made
        'if defender.hp<defender.hpmax*0.3 and rnd_range(1,6)+rnd_range(1,6)<defender.intel+defender.diet then defender.aggr=2
    endif
    if local_debug=1 then dprint "DEBUG MESSAGE dam:"& b
    return defender
end function

function hitmonster(defender as _monster,attacker as _monster,mapmask() as byte, first as short=-1, last as short=-1) as _monster
    dim a as short
    dim b as single
    dim c as short
    dim col as short
    dim noa as short
    dim text as string
    dim wtext as string
    dim mname as string
    dim SLBonus(255) as byte
    dim slbc as byte
    dim as short slot
    slot=player.map
    #ifdef _FMODSOUND
    if _sound=0 or _sound=2 then FSOUND_PlaySound(FSOUND_FREE, sound(3))
    #endif
    if defender.stuff(2)=1 then mname="flying "
    mname=mname &defender.sdesc
    if first=-1 or last=-1 then
        first=0
        noa=attacker.hpmax
    else
        noa=last
    endif
    
    for a=first to noa
        if crew(a).hp>0 and crew(a).onship=0 and crew(a).talents(27)>0 then
            slbc+=1
            SLBonus(slbc)=1
        endif
    next
    slbc=1
    for a=first to noa
        if crew(a).hp>0 and crew(a).onship=0 and crew(a).disease=0 and distance(defender.c,attacker.c)<=attacker.secweapran(a)+1.5 then
            slbc+=1
            if distance(defender.c,attacker.c)>1.5 then
                if rnd_range(1,20)-player.tactic+tohit_gun(a)+attacker.secweapthi(a)+SLBonus(slbc)>13+defender.move*5 then 
                    b=b+attacker.secweap(a)+addtalent(3,11,.1)+addtalent(a,26,.1)
                    if a>5 then gainxp(a) 
                endif
            else
                if rnd_range(1,20)-player.tactic+tohit_close(a)+SLBonus(slbc)>13+defender.move*5 then 
                    b=b+maximum(attacker.secweapc(a),attacker.secweap(a))+addtalent(3,11,.1)+addtalent(a,25,.1)+crew(a).augment(2)/10
                    if a>5 then gainxp(a)
                endif
            endif
        endif
    next
    text="You attack the "&defender.sdesc &"."
    if distance(defender.c,attacker.c)>1.5 then b=b+1-int(distance(defender.c,attacker.c)/2)
    b=cint(b)-player.tactic+addtalent(3,10,1)
    if b<0 then b=0
    if b>0 then
       defender.target=attacker.c
       b=b-defender.armor
       if b>0 then
            text=" You hit for " & b &" points of damage." 
            defender.hp=defender.hp-b
            if defender.hp/defender.hpmax<0.8 then wtext ="The " & mname &" is slightly "&defender.dhurt &" "
            if defender.hp/defender.hpmax<0.5 then wtext ="The " & mname &" is "&defender.dhurt &" "
            if defender.hp/defender.hpmax<0.3 then wtext ="The " & mname &" is badly "&defender.dhurt &" "
            text=text &wtext
            col=10
        else
            text=text &" You don't penetrate the "&mname &" armor."
            col=14 
        endif
    else
        text=text &" your fire misses. "
        col=14
    endif
    if defender.hp<=0 then
        text=text &" the "& mname &" "&defender.dkill
        if defender.made=44 then player.questflag(12)=28
        if defender.made=83 then player.questflag(20)+=1
        if defender.made=84 then player.questflag(20)+=2
        player.alienkills=player.alienkills+1
        if defender.allied>0 then factionadd(0,defender.allied,1)
        if defender.enemy>0 then factionadd(0,defender.enemy,-1)
        if defender.slot>=0 then planets(slot).mon_killed(defender.slot)+=1
    else
        if defender.hp=1 and b>0 and defender.aggr<>2 then 
            if rnd_range(1,6)+rnd_range(1,6)<defender.intel+defender.diet then
                defender.aggr=2
                text=text &"the " &mname &" is critically hurt and tries to FLEE. "            
                defender=movemonster(defender, attacker.c, mapmask(),tmap())   
            endif
        else
            if defender.aggr>0 and defender.hp<defender.hpmax then
                if distance(defender.c,attacker.c)<=1.5 or defender.intel+rnd_range(1,6)>attacker.invis then
                    defender.aggr=0
                    text=text &" the "&mname &" tries to defend itself."
                else
                    text=text &" the "&mname &" looks confused into your general direction"
                endif
            endif
        endif
    endif
    dprint text,col
    return defender
end function


function clear_gamestate() as short
    dim as short a,x,y
    dim d_crew as _crewmember
    dim d_planet as _planet
    dim d_ship as _ship
    dim d_map as _stars
    dim d_fleet as _fleet
    dim d_station as _station
    dim d_drifter as _driftingship
    dim d_item as _items
    dim d_share as _share
    dim d_company as _company
    dim d_portal as _transfer
    player=d_ship
    
    for a=0 to 128
        crew(a)=d_crew
    next
    
    for a=0 to laststar+wormhole
        map(a)=d_map
    next
    wormhole=8
    
    for a=0 to max_maps
        planets(a)=d_planet
        for x=0 to 60
            for y=0 to 20
                planetmap(x,y,a)=0
            next
        next
    next
    lastplanet=0
    
    for a=0 to lastspecial
        specialplanet(a)=0
    next
    
    for a=0 to lastfleet
        fleet(a)=d_fleet
    next
    lastfleet=0
    
    for a=1 to lastdrifting
        drifting(a)=d_drifter
    next
    lastdrifting=16
    
    
    for a=0 to 25000
        item(a)=d_item
    next
    lastitem=0
    
    Wage=10
    basis(0)=d_station
    basis(0).c.x=50
    basis(0).c.y=20
    basis(0).discovered=1
    basis(0)=makecorp(0)
    
    basis(1)=d_station
    basis(1).c.x=10
    basis(1).c.y=25
    basis(1).discovered=1
    basis(1)=makecorp(0)
    
    basis(2)=d_station
    basis(2).c.x=75
    basis(2).c.y=10
    basis(2).discovered=1
    basis(2)=makecorp(0)
    
    basis(3)=d_station
    basis(3).c.x=-1
    basis(3).c.y=-1
    basis(3).discovered=0
    
    baseprice(1)=50
    baseprice(2)=200
    baseprice(3)=500
    baseprice(4)=1000
    baseprice(5)=2500
    
    for a=0 to 5
        avgprice(a)=0
    next
    for a=0 to 4
        companystats(a)=d_company
    next
    for a=0 to 2047
        shares(a)=d_share
    next
    lastshare=0
    
    
    for a=0 to 20
        flag(a)=0
    next
    
    for a=0 to lastflag
        artflag(a)=0
    next
    
    for a=0 to 10
        basis(a).inv(1).n="Food"
        basis(a).inv(1).v=rnd_range(1,6)+4
        basis(a).inv(1).p=50
        
        basis(a).inv(2).n="Basic Goods"
        basis(a).inv(2).v=rnd_range(1,7)+3
        basis(a).inv(2).p=200
        
        basis(a).inv(3).n="Tech Goods"
        basis(a).inv(3).v=rnd_range(1,8)+2
        basis(a).inv(3).p=500
        
        basis(a).inv(4).n="Luxury Goods"
        basis(a).inv(4).v=rnd_range(1,8)+1
        basis(a).inv(4).p=1000
        
        basis(a).inv(5).n="Weapons"
        basis(a).inv(5).v=rnd_range(1,8)
        basis(a).inv(5).p=2500
    next
    
    for a=0 to 255
        portal(a)=d_portal
    next
    
    
    return 0
end function

dim as byte attempts

ERRORMESSAGE:
e=err
text=*ERMN()
text=mid(text,81) 
text=__VERSION__ &" Error #"&e &" in "& " "&erl &":" & *ERFN() &" " & text
f=freefile
open "error.log" for append as #f

print #f,text 
close #f 
locate 10,10
set__color( 12,0)
print "ERROR: Please inform the author and send him the file error.log"
print "matthias.mennel@gmail.com"
set__color( 14,0)
print text
sleep
if attempts=0 then
    print "Trying to save game"
    savegame()
    attempts=26
else
    print "Failed to save game."
endif
print "key to exit"
sleep