

function earthquake(t as _tile,dam as short)as _tile
    dim roll as short
    if t.shootable=1 then
        t.hp=t.hp-dam
        if t.hp<=0 then t=tiles(t.turnsinto)
    endif
    if t.no<41 and t.no<>1 and t.no<>2 and t.no<>26 and t.no<>20 and t.no<>21 then
        if t.no=6 or t.no=5 then t=tiles(3)
        if t.no=7 or t.no=8 and rnd_range(1,100)<33+dam then t=tiles(4)
        if t.no=20 and rnd_range(1,100)<33+dam then t=tiles(rnd_range(1,2))
        if rnd_range(1,100)<15 and t.no<>18 then t=tiles(47)
    endif
    return t
end function

function hpdisplay(a as _monster) as short
    dim as short hp,b,c,x,y,l
    hp=0
    a.hpmax=0
    a.hp=0
    for b=1 to 128
        if crew(b).hpmax>0 and crew(b).onship=0 then a.hpmax+=1
        if crew(b).hp>0 and crew(b).onship=0  then a.hp+=1
        if crew(b).hp>0 and crew(b).onship=0 then hp=hp+1
    next
    
    set__color( 15,0)
    draw string((_mwx+2)*_fw1,0*_fh1),"Status ",,font2,custom,@_col
    set__color( 11,0)
    draw string((_mwx+2)*_fw1+7*_fw2,0*_fh2),"(",,font2,custom,@_col
    draw string((_mwx+2)*_fw1+10*_fw2,0*_fh2),""&a.hpmax &"/",,font2,custom,@_col 
    if a.hp/a.hpmax<.7 then set__color( 14,0)
    if a.hp/a.hpmax<.4 then set__color( 12,0)
    draw string((_mwx+2)*_fw1+13*_fw2,0*_fh2) ,""&a.hp,,font2,custom,@_col
    set__color( 11,0)
    draw string((_mwx+2)*_fw1+16*_fw2,0*_fh2), ")",,font2,custom,@_col
   
    for y=2 to 6
        for x=1 to 15
            c=c+1
            if crew(c).hpmax>0 and crew(c).onship=0 then
                l=y
                if crew(c).hp>0  then
                    
                    set__color( 14,0)
                    if crew(c).hp=crew(c).hpmax then set__color( 10,0)
                    if crew(c).disease>0 then set__color( 192,0)
                    if _HPdisplay=1 then
                        draw string((_mwx+2)*_fw1+(x-1)*_fw2,(y-1)*_fh2),crew(c).icon,,font2,custom,@_col       
                    else
                        draw string((_mwx+2)*_fw1+(x-1)*_fw2,(y-1)*_fh2),""&crew(c).hp,,font2,custom,@_col       
                    endif
                else
                    set__color( 12,0)
                    draw string((_mwx+2)*_fw1+(x-1)*_fw2,(y-1)*_fh2), "X",,font2,custom,@_col
                endif
            endif
        next
    next
    return l
end function

function dplanet(p as _planet,orbit as short,scanned as short) as short
    dim a as short
    dim as single plife
    dim text as string
    dim as short debug
    debug=1
    draw_border(0)
      
    set__color( 15,0)
    draw string((_mwx+2)*_fw1,1*_fh2), "Scanning Results:",,font2,custom,@_col
    
    set__color( 11,0)
    draw string((_mwx+2)*_fw1,2*_fh2), "Planet in orbit " & orbit,,font2,custom,@_col
    draw string((_mwx+2)*_fw1,3*_fh2), scanned &" km2 scanned",,font2,custom,@_col
    draw string((_mwx+2)*_fw1,5*_fh2), p.water &"% Liq. Surface",,font2,custom,@_col
    text=atmdes(p.atmos) &" atmosphere"
    textbox(text,(_mwx+3),(7*_fh2)/_fh1,16,11,0)    
    draw string((_mwx+2)*_fw1,12*_fh2), "Gravity:"&p.grav &"g",,font2,custom,@_col
    set__color( 10,0)
    if p.grav<1 then draw string(62*_fw1+13*_fw2,12*_fh2), "(Low)",,font2,custom,@_col
    set__color( 14,0)
    if p.grav>1.5 then draw string(62*_fw1+13*_fw2,12*_fh2), "(High)",,font2,custom,@_col
    set__color( 11,0)
            
    
    draw string((_mwx+2)*_fw1,13*_fh2), "Avg. Temperature",,font2,custom,@_col
    draw string((_mwx+2)*_fw1+_fw2,14*_fh2), p.temp &" "&chr(248)&"C ",,font2,custom,@_col
    draw string((_mwx+2)*_fw1+_fw2,15*_fh2), c_to_f(p.temp) &" "&chr(248)&"F ",,font2,custom,@_col
    if p.rot>0 then
        draw string((_mwx+2)*_fw1,17*_fh2),"Rot.:"&p.rot*24 &" h",,font2,custom,@_col
    else
        draw string((_mwx+2)*_fw1,17*_fh2),"Rot.: Nil",,font2,custom,@_col
    endif
    
    select case p.highestlife*100
    case is=0
        set__color(c_gre,0)
        draw string((_mwx+2)*_fw1,20*_fh2),"No Lifeforms",,font2,custom,@_col
    case 0 to 10
        set__color(11,0)
        draw string((_mwx+2)*_fw1,20*_fh2),"Lifeforms:",,font2,custom,@_col
        draw string((_mwx+2)*_fw1,21*_fh2),p.highestlife*100 &" % probability",,font2,custom,@_col
        set__color(c_gre,0)
        draw string((_mwx+2)*_fw1,22*_fh2),"Very Low",,font2,custom,@_col
    case 11 to 20
        set__color(11,0)
        draw string((_mwx+2)*_fw1,20*_fh2),"Lifeforms:",,font2,custom,@_col
        draw string((_mwx+2)*_fw1,21*_fh2),p.highestlife*100 &" % probability",,font2,custom,@_col
        set__color(c_gre,0)
        draw string((_mwx+2)*_fw1,22*_fh2),"Low",,font2,custom,@_col
    
    case 50 to 80
        set__color(11,0)
        draw string((_mwx+2)*_fw1,20*_fh2),"Lifeforms:",,font2,custom,@_col
        set__color(c_yel,0)
        draw string((_mwx+2)*_fw1,21*_fh2),p.highestlife*100 &" % probability",,font2,custom,@_col
    
    case 81 to 90
        set__color(11,0)
        draw string((_mwx+2)*_fw1,20*_fh2),"Lifeforms:",,font2,custom,@_col
        draw string((_mwx+2)*_fw1,21*_fh2),p.highestlife*100 &" % probability",,font2,custom,@_col
        set__color(c_red,0)
        draw string((_mwx+2)*_fw1,22*_fh2),"High",,font2,custom,@_col
    
    case is>90 
        set__color(11,0)
        draw string((_mwx+2)*_fw1,19*_fh2),"Lifeforms:",,font2,custom,@_col
        draw string((_mwx+2)*_fw1,20*_fh2),p.highestlife*100 &" % probability",,font2,custom,@_col
        set__color(c_red,0)
        draw string((_mwx+2)*_fw1,21*_fh2),"Very High",,font2,custom,@_col
    case else
        set__color(11,0)
        draw string((_mwx+2)*_fw1,19*_fh2),"Lifeforms:",,font2,custom,@_col
        draw string((_mwx+2)*_fw1,20*_fh2),p.highestlife*100 &" % probability",,font2,custom,@_col
        
    end select
    return 0
end function

function blink(byval p as _cords,osx as short) as short
    if _tiles=1 then
        set__color( 11,11)
        draw string (p.x*_fw1,p.y*_fh1)," ",,font1,custom,@_col
    else
        put ((p.x-osx)*_tix,p.y*_tiy),gtiles(85),trans
    endif
    return 0
end function

function cursor(target as _cords,map as short,osx as short) as string
    dim key as string
    dim as short border
    blink(target,osx)    
    key=keyin
    if map>0 then border=0
    if map<=0 then border=1
    'dprint ""&planetmap(target.x,target.y,map)
    if map>0 then
        if planetmap(target.x,target.y,map)<0 then
            if _tiles=0 then
                put ((target.x-osx)*_tix,target.y*_tiy),gtiles(89),trans
            else
                set__color( 0,0)
                draw string (target.x*_fw1,target.y*_fh1)," ",,font1,custom,@_col
            endif
        else
            if target.x>=0 and target.y>=0 and target.x<=60 and target.y<=20 then dtile(target.x-osx,target.y,tiles(planetmap(target.x,target.y,map)),1)
        endif
    else
        set__color( 0,0)
        draw string (target.x*_fw1,target.y*_fh1)," ",,font1,custom,@_col
    endif
    set__color( 11,0)
    target=movepoint(target,getdirection(key),1,border)
    return key
end function


function mondis(enemy as _monster) as string
    dim text as string
    if enemy.hp<=0 then text=text &"A dead "
    text=text &enemy.ldesc
    if enemy.hpmax=enemy.hp then
        text=text &" unhurt"
    else
        if enemy.hp>0 then
            if enemy.hp<2 then
                text=text &" badly hurt"
            else
                text=text &" hurt"
            endif
        endif
    endif
    if enemy.stuff(9)=0 then
    if rnd_range(1,6)+rnd_range(1,6)+player.science(1)>9 then enemy.stuff(10)=1
    if rnd_range(1,6)+rnd_range(1,6)+player.science(1)>10 then enemy.stuff(11)=1
    if rnd_range(1,6)+rnd_range(1,6)+player.science(1)>11 then enemy.stuff(12)=1
    enemy.stuff(9)=enemy.stuff(10)+enemy.stuff(11)+enemy.stuff(12)
    endif
    if enemy.stuff(10)=1 then text=text &"(" &enemy.hpmax &"/" &enemy.hp &")"
    if enemy.stuff(11)=1 then text=text &" W:" &enemy.weapon
    if enemy.stuff(12)=1 then text=text &" A:" &enemy.armor
    if enemy.hp>0 and enemy.aggr=0 then text=text &". it is attacking!"
    return text
end function

function draw_border(xoffset as short) as short
    dim as short fh1,fw1,fw2,a
    if _tiles=0 then
        fh1=16
        fw1=8
        fw2=_fw2
    else
        fh1=_fh1
        fw1=_fw1
        fw2=_fw2
    endif
    set__color( 224,1)
    if xoffset>0 then draw string(xoffset*fw2,21*_fh1),chr(195),,Font1,Custom,@_col
    for a=(xoffset+1)*fw2 to (_mwx+1)*_fw1 step fw1
        draw string (a,21*_fh1),chr(196),,Font1,custom,@_col
    next
    for a=0 to _screeny-fh1 step fh1
        draw string ((_mwx+1)*_fw1,a),chr(179),,Font1,custom,@_col
    next
    draw string ((_mwx+1)*_fw1,21*_fh1),chr(180),,Font1,custom,@_col
    set__color( 11,0)
    return 0
end function


sub show_stars(bg as short=0)
    dim as uinteger alphav
    dim as short a,b,x,y,navcom,mask,ti_no
    dim as short reveal
    dim as _cords p,p1,p2
    dim range as integer
    dim as single dx,dy,l,x1,y1,vis
    dim m as _monster
    dim as short debug
    
    dim vismask(sm_x,sm_y) as byte
    
    
    if bg<2 then
        player.osx=player.c.x-_mwx/2
        player.osy=player.c.y-10
        if player.osx<=0 then player.osx=0
        if player.osy<=0 then player.osy=0
        if player.osx>=sm_x-_mwx then player.osx=sm_x-_mwx
        if player.osy>=sm_y-20 then player.osy=sm_y-20
    endif
    m.sight=player.sensors+5.5-player.sensors/2
    m.c=player.c
    makevismask(vismask(),m,-1)
    navcom=findbest(52,-1)
    for x=player.c.x-1 to player.c.x+1
        for y=player.c.y-1 to player.c.y+1
            if x>=0 and y>=0 and x<=sm_x and y<=sm_y then vismask(x,y)=1
        next
    next
    
    for x=player.c.x-10 to player.c.x+10
        for y=player.c.y-10 to player.c.y+10
            if x>=0 and y>=0 and x<=sm_x and y<=sm_y then
                if vismask(x,y)=1 then
                    p.x=x
                    p.y=y
                    if distance(p,player.c)>player.sensors then vismask(x,y)=2
                endif
            endif
        next
    next
    
    if bg>0 then
        for x=0 to _mwx
            for y=0 to 20
                set__color( 1,0)
                if debug=44 then draw string (x*_fw1,y*_fh1),""&spacemap(x+player.osx,y+player.osy),,FONT1,custom,@_col
                    
                if spacemap(x+player.osx,y+player.osy)=1 and navcom>0 then 
                    if _tiles=0 then
                        alphav=192
                        if vismask(x+player.osx,y+player.osy)=1 then alphav=255
                        put (x*_fw1+1,y*_fh1+1),gtiles(50),alpha,alphav
                        
                    else
                        draw string (x*_fw1,y*_fh1),".",,FONT1,custom,@_col
                    endif
                endif
                if spacemap(x+player.osx,y+player.osy)>=2 and  spacemap(x+player.osx,y+player.osy)<=5 then 
                    if _tiles=0 then
                        alphav=192
                        if vismask(x+player.osx,y+player.osy)=1 then alphav=255
                        put (x*_fw1+1,y*_fh1+1),gtiles(abs(spacemap(x+player.osx,y+player.osy))+49),alpha,alphav
                    else                        
                        set__color( rnd_range(48,59),1)
                        if spacemap(x+player.osx,y+player.osy)=2 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(48,59),1)
                        if spacemap(x+player.osx,y+player.osy)=3 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(96,107),1)
                        if spacemap(x+player.osx,y+player.osy)=4 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(144,155),1)
                        if spacemap(x+player.osx,y+player.osy)=5 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(192,203),1)
                        draw string (x*_fw1,y*_fh1),chr(176),,Font1,custom,@_col
                    endif
                endif
                if spacemap(x+player.osx,y+player.osy)>=6 and spacemap(x+player.osx,y+player.osy)<=20 then
                    ti_no=abs(spacemap(x+player.osx,y+player.osy))
                    if ti_no>10 then ti_no-=10
                    if _tiles=0 then 
                        alphav=192
                        if vismask(x+player.osx,y+player.osy)=1 then alphav=255
                        put (x*_fw1+1,y*_fh1+1),gtiles(ti_no+49),alpha,alphav
                    else
                        if ti_no=6 then set__color( 2,0)
                        if ti_no=7 then set__color( 10,0)
                        if ti_no=8 then set__color( 4,0)
                        if ti_no=9 then set__color( 12,0)
                        if ti_no=10 then set__color( 3,0)
                        draw string (x*_fw1,y*_fh1),":",,Font1,custom,@_col
                        
                    endif
                endif
            next
        next
    endif
    if debug=25 then
        for a=firstwaypoint to lastwaypoint
            set__color( 11,0)
            if a>=firststationw then set__color( 15,0)
            if targetlist(a).x-player.osx>=0 and targetlist(a).x-player.osx<=60 and targetlist(a).y-player.osy>=0 and targetlist(a).y-player.osy<=20 then
                draw string((targetlist(a).x-player.osx)*_fw1,(targetlist(a).y-player.osy)*_fh1),";",,Font1,Custom,@_tcol
            endif
        next
    endif
    set__color( 1,0)
    for x=player.c.x-10 to player.c.x+10
        for y=player.c.y-10 to player.c.y+10
            if x-player.osx>=0 and y-player.osy>=0 and x-player.osx<=60 and y-player.osy<=20 and x>=0 and y>=0 and x<=sm_x and y<=sm_y then
                p.x=x
                p.y=y
                if vismask(x,y)>0 and distance(p,player.c)<player.sensors+0.5 then 
                    if spacemap(x,y)<=0 then reveal=1
                    if spacemap(x,y)=0 then spacemap(x,y)=1
                    if spacemap(x,y)=-2 then spacemap(x,y)=2
                    if spacemap(x,y)=-3 then spacemap(x,y)=3
                    if spacemap(x,y)=-4 then spacemap(x,y)=4
                    if spacemap(x,y)=-5 then spacemap(x,y)=5
                endif
                locate y+1-player.osy,x+1-player.osx,0
                set__color( 1,0)
                if abs(spacemap(x,y))=1 and navcom>0 and vismask(x,y)>0 and distance(p,player.c)<player.sensors+0.5  then
                    if _tiles=1 then
                        draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),".",,Font1,custom,@_col
                    else
                        
                        alphav=192
                        if vismask(x,y)=1 then alphav=255
                        put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(50),alpha,alphav
                    endif
                endif
                if abs(spacemap(x,y))>=2 and abs(spacemap(x,y))<=5 and vismask(x,y)>0  and distance(p,player.c)<player.sensors+0.5 then 
                    if _tiles=1 then
                        set__color( rnd_range(48,59),1,vismask(x,y))
                        if spacemap(x,y)=2 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(48,59),1,vismask(x,y))
                        if spacemap(x,y)=3 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(96,107),1,vismask(x,y))
                        if spacemap(x,y)=4 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(144,155),1,vismask(x,y))
                        if spacemap(x,y)=5 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then set__color( rnd_range(192,203),1,vismask(x,y))
                        draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),chr(177),,Font1,custom,@_col 
                    else                        
                        alphav=192
                        if vismask(x,y)=1 then alphav=255
                        put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(51),alpha,alphav
                        if spacemap(x,y)=2 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(51),alpha,alphav
                        if spacemap(x,y)=3 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(52),alpha,alphav
                        if spacemap(x,y)=4 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(53),alpha,alphav
                        if spacemap(x,y)=5 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8 then put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(54),alpha,alphav
                    endif
                endif
                if abs(spacemap(x,y))>=6 and abs(spacemap(x,y)<=17) and vismask(x,y)>0 and distance(p,player.c)<player.sensors+0.5 then
                    if (spacemap(x,y)>=6 and spacemap(x,y)<=17) or rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)>8  then 
                        if _tiles=0 then
                            alphav=192
                            if vismask(x,y)=1 then alphav=255
                            put ((x-player.osx)*_tix+1,(y-player.osy)*_tiy+1),gtiles(49+abs(spacemap(x,y))),alpha,alphav
                        else
                            if abs(spacemap(x,y))>8 then set__color( 3,0,vismask(x,y))
                            if abs(spacemap(x,y))=6 then set__color( 9,0,vismask(x,y))
                            if abs(spacemap(x,y))=7 then set__color( 113,0,vismask(x,y))
                            if abs(spacemap(x,y))=8 then set__color( 53,0,vismask(x,y))
                            draw string (x*_fw1-player.osx*_fw1,y*_fh1-player.osy*_fh1),":",,Font1,custom,@_col
                        endif
                        if spacemap(x,y)<=-6 then ano_money+=5
                        spacemap(x,y)=abs(spacemap(x,y))
                    else
                        set__color( 1,0)
                        if navcom>0 then draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),".",,Font1,custom,@_col
                    endif
                endif
            endif
        next
    next


    a=findbest(51,-1)
    if a>0 or debug=4 then
        if debug=4 then a=1
        for b=6 to lastfleet
            x=fleet(b).c.x
            y=fleet(b).c.y
            locate y+1-player.osy,x+1-player.osx,0
            if (vismask(x,y)=1 and (distance(player.c,fleet(b).c)<player.sensors or distance(player.c,fleet(b).c)<2)) or debug=4 then
                set__color( 11,0) 
                if item(a).v1=1 then 'No Friend Foe
                    set__color( 11,0)
                    if _tiles=0 then
                        put ((x-player.osx)*_fw1,(y-player.osy)*_fh1),gtiles(86),trans
                    else
                        draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),"s",,Font1,custom,@_col
                    endif
                    if fleet(b).fighting>0 then  
                        set__color( 12,0)
                        draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),"X",,Font2,custom,@_col
                    endif
                else
                    
                    if _tiles=0 then
                        put ((x-player.osx)*_fw1,(y-player.osy)*_fh1),gtiles(86),trans
                        if fleet(b).ty=1 or fleet(b).ty=3 then put ((x-player.osx)*_fw1,(y-player.osy)*_fh1),gtiles(67),trans
                        if fleet(b).ty=2 or fleet(b).ty=4 then put ((x-player.osx)*_fw1,(y-player.osy)*_fh1),gtiles(68),trans
                    else
                        if fleet(b).ty=1 or fleet(b).ty=3 then set__color( 10,0)
                        if fleet(b).ty=2 or fleet(b).ty=4 then set__color( 12,0)
                        if fleet(b).ty=5 then set__color( 5,0)
                        if fleet(b).ty=6 then set__color( 8,0)
                        if fleet(b).ty=7 then set__color( 8,0)
                        draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),"s",,Font1,custom,@_col
                    endif
                    
                    if fleet(b).fighting>0 then  
                        set__color( 12,0)
                        draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),"X",,Font2,custom,@_col
                    endif
                endif
                if debug=4 then
                    draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),""&fleet(b).mem(0).engine &" No:"& b,,Font2,custom,@_col
                endif
            endif
        next
    endif
    
    for b=3 to lastfleet
        if fleet(b).ty=10 then 'Eris
            if vismask(fleet(b).c.x,fleet(b).c.y)=1 then
                x=fleet(b).c.x
                y=fleet(b).c.y
                if _tiles=0 then
                    put ((x-player.osx)*_fw1,(y-player.osy)*_fh1),gtiles(gt_no(88)),trans
                else
                    set__color( rnd_range(1,15),0)
                    draw string ((x-player.osx)*_fw1,(y-player.osy)*_fh1),"@",,Font1,custom,@_col
                endif
            endif
        endif
    next
    for x=1 to lastdrifting
        if drifting(x).x<0 then drifting(x).x=0
        if drifting(x).y<0 then drifting(x).y=0
        if drifting(x).x>sm_x then drifting(x).x=sm_x
        if drifting(x).y>sm_y then drifting(x).y=sm_y
        p.x=drifting(x).x
        p.y=drifting(x).y
        
        if planets(drifting(x).m).flags(0)=0 then
            set__color( 7,0,vismask(p.x,p.y))
            if drifting(x).s=20 then set__color( 15,0,vismask(p.x,p.y))
            if (a>0 and vismask(p.x,p.y)=1 and distance(player.c,p)<player.sensors) or drifting(x).p>0 then
                if p.x+1-player.osx>=0 and p.x+1-player.osx<=_mwx+1 and p.y+1-player.osy>=0 and p.y+1-player.osy<=21 then 
                    if _tiles=0 then
                        if drifting(x).g_tile.x=0 or drifting(x).g_tile.x=5 or drifting(x).g_tile.x>9 then drifting(x).g_tile.x=rnd_range(1,4)
                        alphav=192
                        if vismask(p.x,p.y)=1 then alphav=255
                        put ((p.x-player.osx)*_fw1,(p.y-player.osy)*_fh1),stiles(drifting(x).g_tile.x,drifting(x).g_tile.y),alpha,alphav
                    else
                        draw string ((p.x-player.osx)*_fw1,(p.y-player.osy)*_fh1),"s",,Font1,custom,@_col
                    endif
                    if debug=111 then draw string ((p.x-player.osx)*_fw1,(p.y-player.osy)*_fh1),":"&vismask(p.x,p.y),,Font1,custom,@_col
                    if drifting(x).p=0 then walking=0
                    drifting(x).p=1                
                endif
            endif
        endif
    next
    if show_NPCs>0 then
        for a=3 to lastfleet
            x=fleet(a).c.x-player.osx
            y=fleet(a).c.y-player.osy
            if x>=0 and x<=_mwx and y>=0 and y<=20 then
                if fleet(a).ty=1 or fleet(a).ty=3 then set__color( 10,0)
                if fleet(a).ty=2 or fleet(a).ty=4 then set__color( 12,0)
                if fleet(a).ty=5 then set__color( 5,0)
                if fleet(a).ty=6 then set__color( 8,0)
                if fleet(a).ty=7 then set__color( 6,0)
                draw string (x*_fw1,(y)*_fh1),"s",,Font1,custom,@_col
            endif
            x=targetlist(fleet(a).t).x-player.osx
            y=targetlist(fleet(a).t).y-player.osy
            if x>=0 and x<=60 and y>=0 and y<=20 then
                set__color( 15,0)
                draw string (x*_fw1,y*_fh1),"*",,Font1,custom,@_col
            endif
        next
    endif
    if show_civs=1 then
        for a=0 to 1
            x=civ(a).home.x-player.osx
            y=civ(a).home.y-player.osy
            if x>=0 and x<=_mwx and y>=0 and y<=20 then
                set__color( 11,0)
                draw string ((x)*_fw1,(y)*_fh1)," "&a,,Font1,custom,@_col
            endif
        next
    endif
    set__color( 11,0)
    for a=1 to lastcom
        if coms(a).c.x>player.osx and coms(a).c.x<player.osx+60 and coms(a).c.y>player.osy and coms(a).c.y<player.osy+20 then
            draw string ((coms(a).c.x-player.osx)*_fw1,(coms(a).c.y-player.osy)*_fh1),trim(coms(a).t),,Font2,custom,@_col
        endif
    next
    
    for a=0 to laststar+wormhole
        if map(a).spec<=7 then
            vis=maximum(player.sensors+.5,(map(a).spec)-2)
        else
            vis=0
        endif
            
        if (vismask(map(a).c.x,map(a).c.y)=1 and distance(map(a).c,player.c)<=vis) or map(a).discovered>0 then 
            if map(a).discovered=0 and walking<10 then walking=0
            display_star(a,vismask(map(a).c.x,map(a).c.y))
        endif
    next
    

'    
    for a=1 to lastprobe
        x=probe(a).x-player.osx
        y=probe(a).y-player.osy
        if x>=0 and y>=0 and x<=_mwx and y<=20 then
            if _tiles=0 then 
               put ((x)*_fw1,(y)*_fh1),gtiles(gt_no(2117+probe(a).p)),trans
            else
                set__color( _shipcolor,0)
                draw string (x*_fw1,y*_fh1),"s",,Font1,custom,@_col
            endif
        endif
    next
    for a=0 to 2
        if basis(a).c.x>0 and basis(a).c.y>0 then
            if basis(a).discovered>0 then display_station(a,vismask(basis(a).c.x,basis(a).c.y))
        endif
    next
    if walking=10 and reveal=1 then
        p1=apwaypoints(lastapwp)
        lastapwp=ap_astar(player.c,p1,apdiff)
        currapwp=0
    endif

end sub

function settactics() as short
    dim as short a
    dim text as string
    screenshot(1)
    text="Tactics:/"
    for a=1 to 5
        if a=player.tactic+3 then
            text=text &" *"&tacdes(a)&"   "
        else
            text=text &"  "&tacdes(a)&"   "
        endif
        text=text &"/"
    next
    text=text &"Exit"
    a=menu(text,,,,1)
    if a<6 then 
        player.tactic=a-3
    endif
    screenshot(2)
    return 0
end function

function screenshot(a as short) as short
    bsave player.desig &".bmp",0
    return 0
end function

function bioreport(slot as short) as short
    dim a as short
    dim as string t,h
    screenshot(1)
    t="Bio Report for /"
    h="/"
    for a=0 to 16
        if planets(slot).mon_seen(a)>0 or planets(slot).mon_killed(a)>0 or planets(slot).mon_caught(a)>0 then 
            t=t & planets(slot).mon_template(a).sdesc &"/"
            h=h & " | "&planets(slot).mon_template(a).ldesc &" | | Visual  :"
            if planets(slot).mon_seen(a)>0 then
                h=h &" Yes"
            else
                h=h &" No"
            endif
            h=h & " | Killed  : "&planets(slot).mon_killed(a)
            h=h & " | Disected: "&planets(slot).mon_disected(a)
            h=h & " | Caught  : "&planets(slot).mon_caught(a) &" | /"
        endif
    next
    t=t &"Exit"
    do
    loop until menu(t,h)
    screenshot(2)
    return 0
end function


function manual() as short
    dim as integer f,offset,c,a,lastspace
    dim lines(512) as string
    dim col(512) as short
    dim as string key,text
    'dim evkey as EVENT
    screenshot(1)
    set__color( 15,0)
    cls
    f=freefile
    if (open ("readme.txt" for input as #f))=0 then
        do
            line input #f,lines(c)
            while len(lines(c))>80
                text=lines(c)
                lastspace=80
                do 
                    lastspace=lastspace-1
                loop until mid(text,lastspace,1)=" "
                lines(c)=left(text,lastspace)
                lines(c+1)=mid(text,lastspace+1,(len(text)-lastspace+1))
                c=c+1
            wend
            c=c+1
            
        loop until eof(f) or c>512
        close #f
        for a=1 to c
            col(a)=11
            if left(lines(a),2)="==" then
                col(a)=7
                col(a-1)=14
            endif
            'if left(lines(a),1)="*" then col(a)=14
        next
        do
            key=""
            cls
            set__color( 11,0)
            for a=1 to 24
                locate a,1
                set__color( col(a+offset),0)
                print lines(a+offset);
            next
            locate 25,15
            set__color( 14,0)
            print "Arrow down and up to browse, esc to exit";
            key=keyin("12346789 ",1)
            if keyplus(key)  then offset=offset-22
            if keyminus(key)  then offset=offset+22
            if offset<0 then offset=0
            if offset>488 then offset=488
        loop until key=key__esc or key=" "
    else
        locate 10,10 
        print "Couldnt open readme.txt"
    endif
    cls
    while inkey<>""
    wend
    screenshot(2)
    return 0
end function

function messages() as short
    dim as short a,ll
    screenshot(1)
    ll=_lines*_fh1/_fh2
    set__color( 15,0)
    cls
    for a=1 to ll
        locate a,1 
        set__color( dtextcol(a),0)
        draw string (0,a*_fh2), displaytext(a),,font2,custom,@_col
    next
    no_key=keyin(,1)
    cls
    screenshot(2)
    return 0
end function


function display_star(a as short,vismask as byte) as short
    dim bg as short
    dim n as short
    dim p as short
    dim as short x,y,debug
    'debug=2
    x=map(a).c.x-player.osx
    y=map(a).c.y-player.osy
    if x<0 or y<0 or x>_mwx or y>20 then return 0
    bg=0
    if spacemap(map(a).c.x,map(a).c.y)>=2 then bg=5
    if spacemap(map(a).c.x,map(a).c.y)=6 then bg=1
    
    if map(a).discovered=2 then bg=1
    for p=1 to 9
        if map(a).planets(p)>0 then
            for n=0 to lastspecial
                set__color( 11,0)
                if map(a).planets(p)=specialplanet(n) and planets(map(a).planets(p)).mapstat>0 then 
                    bg=233
                endif
                if show_specials>0 or debug=2 then
                    if map(a).planets(p)=specialplanet(n) then
                        set__color( 11,0)
                        draw string((map(a).c.x-player.osx+1)*_fw1,(map(a).c.y-player.osy+1)*_fh1) ,""&n,,font2
                    endif
                endif
            next
            if planets(map(a).planets(p)).colony<>0 then bg=246
        endif
    next
    if map(a).discovered<=0 then 
        player.discovered(map(a).spec)=player.discovered(map(a).spec)+1
        map(a).desig=spectralshrt(map(a).spec)&player.discovered(map(a).spec)&"-"&int(disnbase(map(a).c))&"("&map(a).c.x &":"& map(a).c.y &")"
        map(a).discovered=1
    endif
    if _tiles=0 then
        if vismask=1 then
            put (x*_tix,y*_tiy),gtiles(map(a).ti_no),alpha,255
        else
            put (x*_tix,y*_tiy),gtiles(map(a).ti_no),alpha,192
        endif
        set__color( 11,0,vismask)
        if bg=233 then draw string (x*_tix,y*_tiy),"s",,font2,custom,@_tcol
        if debug=1 then draw string ((map(a).c.x-player.osx)*_fw1,(map(a).c.y-player.osy)*_fh1),""&map(a).discovered,,Font1,custom,@_col
        if debug=5 then draw string (x*_tix+_tix,y*_tiy),""&map(a).ti_no &":"&map(a).spec,,Font1,custom,@_col
    else        
        set__color( spectraltype(map(a).spec),bg,vismask)
        locate map(a).c.y+1-player.osy,map(a).c.x+1-player.osx,0
        if map(a).spec<8 then draw string ((map(a).c.x-player.osx)*_fw1,(map(a).c.y-player.osy)*_fh1),"*",,Font1,custom,@_col
        if map(a).spec=8 then     
            set__color( 7,bg)
            draw string ((map(a).c.x-player.osx)*_fw1,(map(a).c.y-player.osy)*_fh1),"o",,Font1,custom,@_col
        endif
            
        if map(a).spec=9 then 
            n=distance(map(a).c,map(map(a).planets(1)).c)/5
            if n<1 then n=1
            if n>6 then n=6
            set__color( 179+n,bg)
            draw string ((map(a).c.x-player.osx)*_fw1,(map(a).c.y-player.osy)*_fh1),"o",,Font1,custom,@_col
        endif
        if map(a).spec=10 then
            set__color(63,bg)
            draw string ((map(a).c.x-player.osx)*_fw1,(map(a).c.y-player.osy)*_fh1),"O",,Font1,custom,@_col
        endif
    endif
    if debug=9 then
        draw string ((map(a).c.x-player.osx)*_tix+_fw2,(map(a).c.y-player.osy)*_tiy+_fh2),""&score_system(a,0),,Font2,custom,@_col
        draw string ((map(a).c.x-player.osx)*_tix+_fw2,(map(a).c.y-player.osy)*_tiy+_fh2*2),""&score_system(a,1),,Font2,custom,@_col
        draw string ((map(a).c.x-player.osx)*_tix+_fw2,(map(a).c.y-player.osy)*_tiy+_fh2*3),""&score_system(a,2),,Font2,custom,@_col
    endif
    return 0
end function

function display_station(a as short,vismask as byte) as short
    dim as short x,y,debug
    debug=1
    basis(a).discovered=1
    x=basis(a).c.x-player.osx
    y=basis(a).c.y-player.osy
    if x<0 or y<0 or x>_mwx or y>20 then return 0
    set__color( 15,0)
    if _tiles=1 then
        draw string (x*_fw1,y*_fh1),"S",,Font1,custom,@_col
    else
        if vismask=1 then
            put ((x)*_tix+1,(y)*_tiy+1),gtiles(44),trans
        else
            put ((x)*_tix+1,(y)*_tiy+1),gtiles(44),alpha,192
        endif    
    endif
    if distance(player.c,basis(a).c)<player.sensors then
        if fleet(a).fighting<>0 then 
            set__color( c_red,0,vismask)
            draw string (x*_fw1,y*_fh1),"x",,Font2,custom,@_col
            if player.turn mod 10=0 then dprint "Station "&a+1 &" is sending a distress signal! They are under attack!",c_red
        endif
    endif
    if debug=1 then draw string (x*_fw1,y*_fh1),""&count_gas_giants_area(basis(a).c,7) &":"& basis(a).inv(9).v ,,Font2,custom,@_col
             
    return 0
end function

function display_ship(show as byte=0) as short
    dim  as short a,mjs,wl',b
    static wg as byte
    dim t as string
    dim as string p,g,s,d,carg
    dim as byte fw1,fh1
    fw1=11
    #ifdef _windows
    Fw1=ext.gfx.font.gettextwidth(FONT1,"W")
    #endif
    Fh1=22
    
    if player.fuel=player.fuelmax then wg=0
    
    set__color( 15,0)
    if findbest(52,-1)>0 then
        draw string (0,21*_fh1), "Pos:"&player.c.x &":"&player.c.y,, font2,custom,@_col
            
    else
        set__color( 14,0)
        draw string (0,21*_fh1), "No navcomp",, font2,custom,@_col
    endif
        
    draw_border(11)
    set__color( 15,0)
    draw string((_mwx+2)*_fw1,0*_fh1),(player.h_sdesc &" "& player.desig),,Font2,custom,@_col 
    set__color( 11,0)
    draw string((_mwx+2)*_fw1,1*_fh2),"HP:"&space(4) &" "&"SP:"&player.shield &" ",,Font2,custom,@_col
    if player.hull<(player.h_maxhull+player.addhull)/2 then set__color( 14,0)
    if player.hull<2 then set__color( 12,0)
    draw string((_mwx+2)*_fw1+3*_fw2,1*_fh2),""&player.hull,,Font2,custom,@_col
    set__color( 11,0)
    p=""&player.pilot(0)
    g=""&player.gunner(0)
    s=""&player.science(0)
    d=""&player.doctor(0)
    if player.pilot(0)<0 then p="-"
    if player.gunner(0)<0 then g="-"
    if player.science(0)<0 then s="-"
    if player.doctor(0)<0 then d="-"
    player.security=0
    for a=2 to 128
       if crew(a).hpmax>=1 and crew(a).typ>=6 then player.security+=1
    next
    
    draw string((_mwx+2)*_fw1,2*_fh2), "Pi:" & p & "  Gu:" &g &"  Sc:" &s,,Font2,custom,@_col
    draw string((_mwx+2)*_fw1,3*_fh2), "Dr:"&d &"  Security:"&player.security ,,Font2,custom,@_col
    draw string((_mwx+2)*_fw1,4*_fh2), "Sensors:"&player.sensors,,Font2,custom,@_col
    
    for a=1 to 5
        if player.weapons(a).made=88 then mjs+=1
        if player.weapons(a).made=89 then mjs+=2
    next
    draw string((_mwx+2)*_fw1,5*_fh2), "Engine :"&player.engine &" ("&player.movepoints(mjs) &" MP)",,Font2,custom,@_col
    set__color( 15,0)
    
    wl=display_ship_weapons()
    if wl+4>_lines then
        _lines=wl+4
        saveconfig(_tiles)        
        _screeny=_lines*_fh1
        screenres _screenx,_screeny,8,2,GFX_WINDOWED
    endif
    draw string((_mwx+2)*_fw1,(wl+4)*_fh2), "Fuel(" &player.fuelmax+player.fuelpod &"):",,Font2,custom,@_col
    set__color( 11,0)
    draw string((_mwx+2)*_fw1+11*_fw2,(wl+4)*_fh2) ,""&fix(player.fuel) ,,Font2,custom,@_col
    
    if player.fuel<player.fuelmax*0.5 then 
        if wg=0 then
            wg=1 
            dprint "Fuel low",14
            if _sound=0 or _sound=2 then 
                #ifdef _FMODSOUND
                FSOUND_PlaySound(FSOUND_FREE, sound(2))                                       
                #endif
            endif    
            if _sound=2 then no_key=keyin(" "&key__enter &key__esc)
        endif
        set__color( 14,0)
        
    endif
            
    if player.fuel<player.fuelmax*0.2 then
        if wg=1 then
            wg=2
            dprint "Fuel very low",12
            if _sound=0 or _sound=2 then 
                #ifdef _FMODSOUND
                FSOUND_PlaySound(FSOUND_FREE, sound(2))
                #endif
            endif
            if _sound=2 then no_key=keyin(" "&key__enter &key__esc)
 
        endif
        set__color( 12,0)
    endif
    
    if player.turn mod 20=0 then low_morale_message
    
    set__color( 11,0)
    draw string((_mwx+2)*_fw1,(wl+2)*_fh2),"Credits: "&Credits(player.money) &"    ",,Font2,custom,@_col
    draw string((_mwx+2)*_fw1,(wl+3)*_fh2),"Turns: "&player.turn,,Font2,custom,@_col
    set__color( 15,0)
    draw string((_mwx+2)*_fw1,wl*_fh2), "Cargo",,font2,custom,@_col
    for a=1 to 10
        carg=""
        if player.cargo(a).x=1 then 
            set__color( 8,1)
        else
            set__color( 10,8)
        endif
        if player.cargo(a).x=1 then carg= "E"
        if player.cargo(a).x=2 then carg= "F"
        if player.cargo(a).x=3 then carg= "B"
        if player.cargo(a).x=4 then carg= "T"
        if player.cargo(a).x=5 then carg= "L"
        if player.cargo(a).x=6 then carg= "W"
        if player.cargo(a).x=7 then carg= "N"
        if player.cargo(a).x=8 then carg= "H"
        if player.cargo(a).x=9 then carg= "U"
        if player.cargo(a).x=10 then carg= "f"
        if player.cargo(a).x=11 then carg= "C"
        if player.cargo(a).x=12 then carg= "?"
        if player.cargo(a).x=13 then carg= "t"
        draw string((_mwx+2)*_fw1+(a-1)*_fw2,(wl+1)*_fh2),carg,,font2,custom,@_col
    next
    if show=1 then
        if _tiles=0 then
            put ((player.c.x-player.osx)*_tix-(_tiy-_tix)/2,(player.c.y-player.osy)*_tiy),stiles(player.di,player.ti_no),trans
        else
            set__color( _shipcolor,0)
            draw string ((player.c.x-player.osx)*_fw1,(player.c.y-player.osy)*_fh1),"@",,Font1,custom,@_col
        endif
    endif
    wl+=6
    
    display_comstring(wl)
    set__color( 11,0)
    if player.tractor=0 then player.towed=0
    return wl+4
end function

function display_comstring(wl as short) as short
    dim as string ws(40)
    dim as short last,b,start,room,needed,parts
    static counter as byte
    counter+=1
    if comstr="" then return 0
    last=string_towords(ws(),comstr,";")
    room=_lines-wl
    needed=last
    parts=needed/room
    if counter>=parts then counter=0
    if parts>1 then
        start=(last/parts)*counter
        last=(last/parts)*(counter+1)
    endif
    if last>40 then last=40
    for b=start to last
        set__color(15,0)
        draw string((_mwx+2)*_fw1,(b+wl-start)*_fh2),ws(b),,Font2,custom,@_col
    next
    return 0
end function


function display_ship_weapons(m as short=0) as short
    dim as short a,b,bg,wl,hasammo
    set__color( 15,0)
    draw string ((_mwx+2)*_fw1,7*_fh2), "Weapons:",,font2,custom,@_col
    set__color( 11,0)
    player.tractor=0
    wl=9
    for a=1 to 5
        if m<>0 and a=m then 
            bg=1
        else
            bg=0
        endif
        if player.weapons(a).desig<>"" then
            wl=wl+2
            set__color( 15,bg)
            if player.weapons(a).reloading>0 then set__color( 7,bg)
            if player.weapons(a).shutdown>0 then set__color( 14,bg)
            draw string((_mwx+2)*_fw1,(8+b)*_fh2),space(25),,font2,custom,@_col
            draw string((_mwx+2)*_fw1,(8+b)*_fh2),trim(player.weapons(a).desig),,font2,custom,@_col
            set__color( 11,bg)
            if player.weapons(a).reloading>0 then set__color( 7,bg)
            if player.weapons(a).dam>0 then
                draw string((_mwx+2)*_fw1+5*_fw2,(8+b+1)*_fh2),space(25),,font2,custom,@_col
                if player.weapons(a).ammomax>0 then
                    hasammo=1
                    'draw string((_mwx+2)*_fw1+14*_fw2,(8+b)*_fh2),"D:"&player.weapons(a).dam+player.loadout,,Font2,custom,@_col
                else
                    draw string((_mwx+2)*_fw1+2*_fw2,(8+b+1)*_fh2),"D:"&player.weapons(a).dam,,Font2,custom,@_col
                endif
                if player.weapons(a).reloading=0 then
                    if player.weapons(a).ammomax>0 then 
                        draw string((_mwx+2)*_fw1+3*_fw2,(8+b+1)*_fh2), "R:"& player.weapons(a).range &"/"& player.weapons(a).range*2 &"/" & player.weapons(a).range*3 &" A:"&player.weapons(a).ammomax &"/" &player.weapons(a).ammo &" ",,Font2,custom,@_col
                    else
                        draw string((_mwx+2)*_fw1+6*_fw2,(8+b+1)*_fh2), "R:"& player.weapons(a).range &"/"& player.weapons(a).range*2 &"/" & player.weapons(a).range*3 &" ",,Font2,custom,@_col
                    endif
                else
                    if player.weapons(a).ammomax>0 then 
                        draw string((_mwx+2)*_fw1+3*_fw2,(8+b+1)*_fh2),space(25),,font2,custom,@_col
                        draw string((_mwx+2)*_fw1+3*_fw2,(8+b+1)*_fh2), "Reloading: "&player.weapons(a).reloading,,Font2,custom,@_col
                    else
                        draw string((_mwx+2)*_fw1+3*_fw2,(8+b+1)*_fh2),space(25),,font2,custom,@_col
                        draw string((_mwx+2)*_fw1+3*_fw2,(8+b+1)*_fh2), "Recharging: "&player.weapons(a).reloading,,Font2,custom,@_col
                    endif
                endif
            endif
            if player.weapons(a).heat>0 then
                set__color( 11,bg)
                if player.weapons(a).heat>100 then set__color( 14,bg)
                if player.weapons(a).heat>250 then set__color( 12,bg)
                draw string((_mwx+3)*_fw1,(8+b+2)*_fh2),space(25),,font2,custom,@_col
                if player.weapons(a).shutdown=0 then
                    draw string((_mwx+4)*_fw1,(8+b+2)*_fh2), "Heat:"& fix(player.weapons(a).heat/25) &"         ",,Font2,custom,@_col
                else
                    draw string((_mwx+4)*_fw1,(8+b+2)*_fh2), "Heat:"& fix(player.weapons(a).heat/25) &"-Shutdown",,Font2,custom,@_col
                endif
                b=b+3
                wl=wl+1
            else
                b=b+2
            endif
            if player.weapons(a).ROF<0 then 
                player.tractor=1
                if player.towed>0 and rnd_range(1,6)+rnd_range(1,6)+player.pilot(0)<8+player.weapons(a).ROF then
                    dprint "Your tractor beam breaks down",14
                    player.tractor=0
                    player.towed=0
                    player.weapons(a)=makeweapon(0)
                endif
            endif
        endif
    next
    b+=1
    if hasammo=1 then 
        set__color(15,0)
        draw string((_mwx+2)*_fw1,(8+b)*_fh2), "Loadout: ",,Font2,custom,@_col
        set__color(11,0)
        draw string((_mwx+2)*_fw1,(9+b)*_fh2), ammotypename(player.loadout)&"s",,Font2,custom,@_col
        draw string((_mwx+2)*_fw1,(10+b)*_fh2), "Damage: "&player.loadout+1,,Font2,custom,@_col
        wl+=4
    endif
    set__color( 11,0)
    return wl
end function


function dtile(x as short,y as short, tiles as _tile,vismask as byte) as short
    dim as short col,bgcol
    locate y+1,x+1,0
    col=tiles.col
    bgcol=tiles.bgcol
    'if tiles.walktru=5 then bgcol=1
    if tiles.col<0 and tiles.bgcol<0 then
        col=col*-1
        bgcol=bgcol*-1
        col=rnd_range(col,bgcol)    
        bgcol=0
    endif
    if _tiles=0 then
        if vismask=1 then
            put (x*_tix,y*_tiy),gtiles(gt_no(tiles.ti_no)),pset
        else
            put (x*_tix,y*_tiy),gtiles(gt_no(tiles.ti_no)),alpha,196
        endif
    else
        if _showvis=0 and vismask>0 and bgcol=0 then 
            bgcol=234
        endif
        set__color( col,bgcol,vismask)
        draw string (x*_fw1,y*_fh1),chr(tiles.tile),,Font1,custom,@_col
    endif
    set__color( 11,0)
    return 0
end function

function display_system(in as short,forcebar as byte=0,hi as byte=0) as short
    dim as short a,b,bg,x,y,localdebug,fw1
    dim as string bl,br
    'localdebug=2
    if _fw1<_tix then
        fw1=_fw1
    else
        fw1=_tix
    endif
    localdebug=0
    if _onbar=0 or forcebar=1 then
        y=21
        x=_mwx/2-2
        bl=chr(180)
        br=chr(195)
    else
        x=((map(in).c.x-player.osx)*fw1-12*_fw2)/_fw1
        y=map(in).c.y+1-player.osy
        if x<0 then x=0
        if _sysmapt=0 then
            if x*fw1+18*_tix>_mwx*fw1 then x=(_mwx*fw1-18*_tix)/fw1
        else
            if x*fw1+24*_fw2>_mwx*fw1 then x=(_mwx*fw1-24*_fw2)/fw1
        endif
        'if x*fw1+(25*_fw2)/fw1>_mwx*fw1 then x=_mwx*fw1-(25*_fw2)/fw1
        bl="["
        br="]"
    endif
    display_sysmap(x*fw1,y*_fh1,in,hi,bl,br)
    set__color( 11,0)
    if localdebug=1 then
        bl=""
        for a=1 to 9
            bl=bl &map(in).planets(a)&" "
            if map(in).planets(a)>0 then
                bl=bl &"ms:"&map(in).planets(a)
            endif
        next
        dprint bl &":"& hi
    endif
    if localdebug=2 then dprint ""&x
    return 0
end function

function display_sysmap(x as short, y as short, in as short, hi as short=0,bl as string,br as string) as short
    dim as short a,b,bg,yof,ptile,alp
    dim t as string
    set__color( 224,0)
    yof=(_fh1-_fh2)/2
    if _sysmapt=0 then
        line (x,y)-(x+19*_tix,y+_tiy+5),RGB(0,0,0),BF
        line (x,y+1)-(x+19*_tix,y+_tiy+5),RGB(0,0,255),B
        'draw string(x,y),bl ,,font1,custom,@_col
        'draw string(x+19*_tix,y),br ,,font1,custom,@_col
        
    else
        draw string(x,y),bl ,,font1,custom,@_col
        draw string (x+_fw2,y+yof), space(25),,font2,custom,@_col
        draw string(x+25*_fw2,y),br ,,font1,custom,@_col
    endif
    set__color( spectraltype(map(in).spec),0)
    if _sysmapt=0 then
        put (x+_fw1,y),gtiles(gt_no(1499+map(in).spec)),trans
    else
        draw string(x+_fw1,y), "*"&space(2),,font1,custom,@_col
    endif
    for a=1 to 9
        bg=0
        if map(in).planets(a)>0 then
            if is_special(map(in).planets(a)) and planets(map(in).planets(a)).mapstat<>0 then bg=233
        endif
        if hi=a then bg=11
        t=" "
        
        if map(in).planets(a)<>0 then
                ptile=0
                alp=255
                if isgasgiant(map(in).planets(a))<>0 then 
                    
                    t="O"
                    if a<6 then 
                        set__color( 162,bg)
                        ptile=1512
                    endif
                    if a=1 then 
                        set__color( 164,bg)
                        ptile=1513
                    endif
                    if a>5 or map(in).spec=10 then 
                        set__color( 63,bg)
                        ptile=1514
                    endif
                endif
                if isasteroidfield(map(in).planets(a))<>0 then 
                    t=chr(176)
                    set__color( 7,bg)
                    ptile=1508
                endif
                if isasteroidfield(map(in).planets(a))=0 and isgasgiant(map(in).planets(a))=0 and map(in).planets(a)>0 then 
                    t="o"
                    ptile=1509
                    
                    if planets(map(in).planets(a)).atmos=0 then planets(map(in).planets(a)).atmos=1
                    if planets(map(in).planets(a)).mapstat=0 then set__color( 7,bg)  
                    if planets(map(in).planets(a)).mapstat=1 then
                        alp=197
                        if planets(map(in).planets(a)).atmos=1 then 
                            set__color( 15,bg)      
                            ptile=1516
                        endif
                        if planets(map(in).planets(a)).atmos>1 and planets(map(in).planets(a)).atmos<7 then 
                            set__color( 101,bg)
                            ptile=1519
                        endif
                        if planets(map(in).planets(a)).atmos>6 and planets(map(in).planets(a)).atmos<12 then 
                            set__color( 210,bg)
                            ptile=1522
                        endif
                        if planets(map(in).planets(a)).atmos>11 then 
                            set__color( 10,bg)
                            ptile=1525
                        endif
                        if planets(map(in).planets(a)).grav<0.8 then ptile+=1
                        if planets(map(in).planets(a)).grav>1.2 then ptile-=1
                    endif
                    if planets(map(in).planets(a)).mapstat=2 then  
                        if planets(map(in).planets(a)).atmos=1 then 
                            set__color( 8,bg)    
                            ptile=1516
                        endif
                        if planets(map(in).planets(a)).atmos>1 and planets(map(in).planets(a)).atmos<7 then 
                            set__color(9,bg)
                            ptile=1519
                        endif
                        if planets(map(in).planets(a)).atmos>6 and planets(map(in).planets(a)).atmos<12 then 
                            set__color(198,bg)
                            ptile=1522
                        endif
                        if planets(map(in).planets(a)).atmos>11 then 
                            set__color( 54,bg)
                            ptile=1525
                        endif
                        if planets(map(in).planets(a)).grav<0.8 then ptile+=1
                        if planets(map(in).planets(a)).grav>1.2 then ptile-=1
                    endif
                endif
            if _sysmapt=0 then
                if ptile>0 then put (x+_tix*(a*1.5+4),y+yof),gtiles(gt_no(ptile)),alpha,alp
                if bg=11 then put (x+_tix*(a*1.5+4),y+yof),gtiles(gt_no(1510)),trans
            else
                
                draw string(x+_fw2*(a*2+4),y+yof),t,,font2,custom,@_col
            endif
        endif
    next
    return 0
end function

function nextplan(p as short,in as short) as short
    dim as short oldp
    oldp=p
    do
        p=p+1
        if p>9 then p=1
    loop until map(in).planets(p)<>0 or p=oldp
    return p
end function

function prevplan(p as short,in as short) as short
    dim as short oldp
    oldp=p
    do
        p=p-1
        if p<1 then p=9
    loop until map(in).planets(p)<>0 or p=oldp
    return p
end function
'

function get_planet_cords(byref p as _cords,mapslot as short) as string
    dim osx as short
    dim as string key
    display_planetmap(mapslot,osx,1)
    display_ship
    do
        cls
        osx=p.x-_mwx/2
        if planets(mapslot).depth>0 then
            if osx<0 then osx=0
            if osx>60-_mwx then osx=60-_mwx
        endif
        if _mwx=60 then osx=0
        
        display_planetmap(mapslot,osx,1)
        draw_border(0)
        if planetmap(p.x,p.y,mapslot)>0 then
            dprint tiles(planetmap(p.x,p.y,mapslot)).desc
        else
            dprint "Unknown"
        endif
        key=cursor(p,mapslot,osx)
        
    loop until key=key__esc or key=key__enter
    
    return key
end function

function getplanet(sys as short,forcebar as byte=0) as short
    dim as short r,p,a,b
    dim as string text,key
    dim as _cords p1
    if sys<0 or sys>laststar then
        dprint ("ERROR:System#:"&sys,14)
        return -1
    endif
    map(sys).discovered=2
    p=liplanet
    if p<1 then p=1
    if p>9 then p=9
    if map(sys).planets(p)=0 then p=nextplan(p,sys)
    for a=1 to 9
        if map(sys).planets(a)<>0 then b=1
    next
    if b>0 then
        dprint "Enter to select, arrows to move,ESC to quit"
        if show_mapnr=1 then dprint map(sys).planets(p)&":"&isgasgiant(map(sys).planets(p))
        do
            display_system(sys,,p)        
            key=""
            key=keyin
            if keyplus(key) or key=key_east or key=key_north then p=nextplan(p,sys)
            if keyminus(key) or key=key_west or key=key_south then p=prevplan(p,sys)
            if key=key_comment then
                if map(sys).planets(p)>0 then
                    dprint "Enter comment on planet: "
                    p1=locEOL
                    planets(map(sys).planets(p)).comment=gettext(p1.x,p1.y,60,planets(map(sys).planets(p)).comment)
                endif
            endif
            if key="q" or key="Q" or key=key__esc then r=-1
            if (key=key__enter or key=key_sc or key=key_la) and map(sys).planets(p)<>0 then r=p
        loop until r<>0
        liplanet=r
        
    else
        r=-1
    endif
    return r
end function

'function getplanet(sys as short,forcebar as byte=0) as short
'    dim as short a,r,p,x,xo,yo
'    dim text as string
'    dim key as string
'    dim firstplanet as short
'    dim lastplanet as short
'    dim p1 as _cords
'    if sys<0 or sys>laststar then
'        dprint ("ERROR:System#:"&sys,14)
'        return -1
'    endif
'    for a=1 to 9
'        if map(sys).planets(a)<>0 then
'            lastplanet=a
'            x=x+1
'        endif
'    next
'    for a=9 to 1 step-1
'        if map(sys).planets(a)<>0 then firstplanet=a
'    next
'    p=liplanet
'    if p<1 then p=1
'    if p>9 then p=9
'    if map(sys).planets(p)=0 then
'        do
'            p=p+1
'            if p>9 then p=1
'        loop until map(sys).planets(p)<>0 or lastplanet=0
'    endif
'    if p>9 then p=firstplanet
'    if lastplanet>0 then
'        if _onbar=0 or forcebar=1 then
'            xo=31
'            yo=22
'        else
'            xo=map(sys).c.x-9-player.osx
'            yo=map(sys).c.y+2-player.osy
'            if xo<=4 then xo=4
'            if xo+18>58 then xo=42
'        endif
'        dprint "Enter to select, arrows to move,ESC to quit"
'        if show_mapnr=1 then dprint map(sys).planets(p)&":"&isgasgiant(map(sys).planets(p))
'        do
'            displaysystem(sys)       
'            if keyplus(key) or a=6 then
'                do
'                    p=p+1
'                    if p>9 then p=1
'                loop until map(sys).planets(p)<>0
'            endif
'            if keyminus(key) or a=4 then
'                do
'                    p=p-1
'                    if p<1 then p=9
'                loop until map(sys).planets(p)<>0
'            endif
'            if p<1 then p=lastplanet
'            if p>9 then p=firstplanet
'            x=xo+(p*2)
'            if left(displaytext(25),14)<>"Asteroid field" or left(displaytext(25),15)<>"Planet at orbit" then dprint "System " &map(sys).desig &"."
'            if map(sys).planets(p)>0 then
'                if planets(map(sys).planets(p)).comment="" then
'                    if isasteroidfield(map(sys).planets(p))=1 then
'                        displaytext(25)= "Asteroid field at orbit " &p &"."
'                    else
'                        if planets(map(sys).planets(p)).mapstat<>0 then
'                            if isgasgiant(map(sys).planets(p))<>0 then
'                                if p>1 and p<7 then displaytext(25)= "Planet at orbit " &p &". A helium-hydrogen gas giant."
'                                if p>6 then displaytext(25)= "Planet at orbit " &p &". A methane-ammonia gas giant."
'                                if p=1 then displaytext(25)= "Planet at orbit " &p &". A hot jupiter."
'                            else
'                                if isgasgiant(map(sys).planets(p))=0 and isasteroidfield(map(sys).planets(p))=0 then displaytext(25)="Planet at orbit " &p &". " &atmdes(planets(map(sys).planets(p)).atmos) &" atm., " &planets(map(sys).planets(p)).grav &"g grav."
'                            endif
'                        else
'                            displaytext(25)= "Planet at orbit " &p &"."
'                        endif
'                    endif
'                endif
'                if planets(map(sys).planets(p)).comment<>"" then
'                    if isasteroidfield(map(sys).planets(p))=1 then
'                        displaytext(25)= "Asteroid field at orbit " &p &": " &planets(map(sys).planets(p)).comment &"."
'                    else
'                        displaytext(25)= "Planet at orbit " &p &": " &planets(map(sys).planets(p)).comment &"."
'                    endif
'                endif
'                dprint ""
'                locate yo,x
'                set__color( 15,3
'                if isgasgiant(map(sys).planets(p))=0 and isasteroidfield(map(sys).planets(p))=0 then print "o"
'                if isgasgiant(map(sys).planets(p))>0 then print "O"
'                if isasteroidfield(map(sys).planets(p))=1 then print chr(176)
'                set__color( 11,0
'            endif
'           
'            if map(sys).planets(p)<0 then
'                if map(sys).planets(p)<0 then
'                    if isgasgiant(map(sys).planets(p))=0 then
'                        displaytext(25)= "Asteroid field at orbit " &p &"."
'                    else
'                        if map(sys).planets(p)=-20001 then displaytext(25)= "Planet at orbit " &p &". A helium-hydrogen gas giant."
'                        if map(sys).planets(p)=-20002 then displaytext(25)= "Planet at orbit " &p &". A methane-ammonia gas giant."
'                        if map(sys).planets(p)=-20003 then displaytext(25)= "Planet at orbit " &p &". A hot jupiter."
'                    endif
'                    dprint ""
'                endif
'                locate yo,x
'                set__color( 15,3
'                if isgasgiant(map(sys).planets(p))=0 then
'                    print chr(176)
'                else
'                    print "O"
'                endif
'                set__color( 11,0
'            endif
'            key=keyin
'            if key=key_comment then
'                dprint "Enter comment on planet: "
'                p1=locEOL
'                planets(map(sys).planets(p)).comment=gettext(p1.x,p1.y,60,planets(map(sys).planets(p)).comment)
'            endif
'            a=Getdirection(key)
'           
'           
'            if key="q" or key="Q" or key=key__esc then r=-1
'            if (key=key__enter or key=key_sc or key=key_la) and map(sys).planets(p)<>0 then r=p
'        loop until r<>0
'        liplanet=r
'    else
'        r=-1
'    endif
'    return r
'end function
'
function display_awayteam(awayteam as _monster, map as short, lastenemy as short, deadcounter as short, ship as _cords, loctime as short,loctemp as single) as short
        dim a as short
        dim c as short
        dim x as short
        dim y as short
        dim xoffset as short
        dim t as string
        static wg as byte
        static wj as byte
        dim thp as short
        dim as string poi
        dim as byte fw1,fh1,l
        dim debug as byte=0
        Fh1=22
        dim osx as short
        osx=awayteam.c.x-_mwx/2
        if planets(map).depth>0 then
            if osx<0 then osx=0
            if osx>=60-_mwx then osx=60-_mwx
        endif
        if _mwx=60 then osx=0
        xoffset=22
        locate 22,1
        set__color( 15,0)
        if awayteam.stuff(8)=1 and player.landed.m=map and planets(map).depth=0 then
            set__color( 15,0)
            locate 22,3
            draw string(0*_fw1,21*_fh1+(_fh1-_fh2)/2), "Pos:"&awayteam.c.x &":"&awayteam.c.y,,Font2,Custom,@_col
        else
            locate 22,1
            set__color( 14,0)
            draw string(0*_fw1,21*_fh1+(_fh1-_fh2)/2), "no satellite",,Font2,Custom,@_col
        endif
        locate 22,15
        set__color( 15,0)
        if loctime=3 then draw string(15*_fw2,21*_fh1+(_fh1-_fh2)/2),"Night",,Font2,Custom,@_col
        if loctime=0 then draw string(15*_fw2,21*_fh1+(_fh1-_fh2)/2)," Day ",,Font2,Custom,@_col
        if loctime=1 then draw string(15*_fw2,21*_fh1+(_fh1-_fh2)/2),"Dawn ",,Font2,Custom,@_col
        if loctime=2 then draw string(15*_fw2,21*_fh1+(_fh1-_fh2)/2),"Dusk ",,Font2,Custom,@_col
        if show_mnr=1 then draw string(15*_fw2,21*_fh1+(_fh1-_fh2)/2),""&map &":"&planets(map).flags(1),,Font2,Custom,@_col
        set__color( 10,0)
        locate 22,xoffset
        if awayteam.invis>0 then
            draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),"Camo",,Font2,Custom,@_col
            xoffset=xoffset+5
        endif
        locate 22,xoffset
        if addtalent(-1,24,0)>0 then 
            draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),"Fast",,Font2,Custom,@_col
            xoffset=xoffset+5
        endif
        if _autopickup=0 then
            draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),"P",,Font2,Custom,@_col
            xoffset+=1    
        endif
        if _autoinspect=0 then
            draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),"I",,Font2,Custom,@_col
            xoffset+=1    
        endif
        if awayteam.helmet=0 then
            draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),"O",,Font2,Custom,@_col
        else
            draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),"C",,Font2,Custom,@_col
        endif
        xoffset+=2
        draw string(xoffset*_fw2,21*_fh1+(_fh1-_fh2)/2),tacdes(player.tactic+3),,Font2,Custom,@_col
        xoffset=xoffset+len(tacdes(player.tactic+3))
        
        draw_border(xoffset)
        
        set__color( 15,0)
        if player.landed.m=map then
            if planetmap(ship.x,ship.y,map)>0 or player.stuff(3)=2 then    
                if _tiles=0 then
                    if vis_test(awayteam.c,ship,0) then 
                        x=ship.x-osx
                        if x<0 then x+=61
                        if x>60 then x-=61
                        put (x*_tix,ship.y*_tiy),stiles(5,player.ti_no),trans
                    endif
                else
                    set__color( _shipcolor,0)
                    draw string((ship.x)*_fw1,ship.y*_fh1),"@",,Font1,custom,@_col
                endif
            endif
        endif        
        if _tiles=0 then
            put ((awayteam.c.x-osx)*_fw1,awayteam.c.y*_fh1),gtiles(gt_no(1000)),trans
        else
            set__color( _teamcolor,0)
            draw string (awayteam.c.x*_fw1,awayteam.c.y*_fh1),"@",,Font1,custom,@_col
        endif    
        l=hpdisplay(awayteam)
        set__color( 11,0)
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2), "Visibility:" &awayteam.sight,,Font2,custom,@_col
        l+=1
        if awayteam.move=0 then draw string((_mwx+2)*_fw1,l*_fh2), "Trp.: None",,Font2,custom,@_col
        if awayteam.move=1 then draw string((_mwx+2)*_fw1,l*_fh2), "Trp.: Hoverplt.",,Font2,custom,@_col
        if awayteam.move=2 then draw string((_mwx+2)*_fw1,l*_fh2), "Trp.: Jetpacks",,Font2,custom,@_col
        if awayteam.move=3 then draw string((_mwx+2)*_fw1,l*_fh2), "Trp.: Jetp&Hover",,Font2,custom,@_col
        if awayteam.move=4 then draw string((_mwx+2)*_fw1,l*_fh2), "Trp.: Teleport",,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2), "Armor :"&awayteam.armor,,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2),"Firearms :"&awayteam.guns_to,,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2), "Melee :"&awayteam.blades_to,,Font2,custom,@_col
        if player.stuff(3)=2 then
            l+=1
            draw string((_mwx+2)*_fw1,l*_fh2),"Alien Scanner",,font2,custom,@_col
            l+=1
            draw string((_mwx+2)*_fw1,l*_fh2),lastenemy-deadcounter &" Lifeforms ",,Font2,custom,@_col
        endif
        calc_resrev
        l+=2
        draw string((_mwx+2)*_fw1,l*_fh2),"Mapped    :"& cint(reward(7)),,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2), "Bio Data  :"& cint(reward(1)),,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2), "Resources :"& cint(reward(2)),,Font2,custom,@_col
        if len(tmap(awayteam.c.x,awayteam.c.y).desc)<18 then
            l+=1
            draw string((_mwx+2)*_fw1,l*_fh2),tmap(awayteam.c.x,awayteam.c.y).desc,,Font2,custom,@_col ';planetmap(awayteam.c.x,awayteam.c.y,map) 
        else 
            dprint tmap(awayteam.c.x,awayteam.c.y).desc '&planetmap(awayteam.c.x,awayteam.c.y,map)
        endif
        
'        if awayteam.move=2 or awayteam.move=3 then
'            
'            draw string((_mwx+2)*_fw1,20*_fh2), key_ju &" for emerg.",,Font2,custom,@_col
'            draw string((_mwx+2)*_fw1,21*_fh2), "Jetpackjump",,Font2,custom,@_col
'        endif
'        if awayteam.move=4 then
'            draw string((_mwx+2)*_fw1,20*_fh2), key_te &" activates",,Font2,custom,@_col
'            draw string((_mwx+2)*_fw1,21*_fh2),"Transporter",,Font2,custom,@_col
'        endif
        if (awayteam.move=2 or awayteam.move=3) and awayteam.hp>0 then
            set__color( 11,0)
            l+=1
            draw string((_mwx+2)*_fw1,l*_fh2), "Jetpackfuel:",,Font2,custom,@_col
            set__color( 10,0)
            if awayteam.jpfuel<awayteam.jpfuelmax*.5 then set__color( 14,0)
            if awayteam.jpfuel<awayteam.jpfuelmax*.3 then set__color( 12,0)
            if awayteam.jpfuel<0 then awayteam.jpfuel=0
            if awayteam.hp>0 then
                draw string((_mwx+2)*_fw1+12*_fw2,l*_fh2), ""&int(awayteam.jpfuel/awayteam.hp),,Font2,custom,@_col
            else
                draw string((_mwx+2)*_fw1+12*_fw2,l*_fh2), ""&awayteam.jpfuel,,Font2,custom,@_col
            endif
        endif
        
        if player.turn mod 15=0 then low_morale_message
        
        set__color( 11,0)
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2),"Oxygen:",,Font2,custom,@_col
        set__color( 10,0)
        if awayteam.oxygen<50 then set__color( 14,0)
        if awayteam.oxygen<25 then set__color( 12,0)
        if awayteam.hp>0 then
            draw string((_mwx+2)*_fw1+7*_fw2,l*_fh2),""&int(awayteam.oxygen/awayteam.hp),,Font2,custom,@_col
        else
            draw string((_mwx+2)*_fw1+7*_fw2,l*_fh2),""&awayteam.oxygen,,Font2,custom,@_col
        endif
        set__color( 11,0)
        l+=2
        draw string((_mwx+2)*_fw1,l*_fh2),"Temp:" &loctemp &chr(248)&"C",,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2),"Gravity:" &planets(map).grav,,Font2,custom,@_col
        l+=2
        draw string((_mwx+2)*_fw1,l*_fh2),"Credits:" &credits(player.money),,Font2,custom,@_col
        l+=1
        draw string((_mwx+2)*_fw1,l*_fh2),"Turn:" &player.turn,,Font2,custom,@_col
        if debug=1 then draw string((_mwx+2)*_fw1,26*_fh2),"life:" &planets(map).life,,Font2,custom,@_col
    
        display_comstring(l+2)

        
    return 0
end function

function shipstatus(heading as short=0) as short
    dim as short c1,c2,c3,c4,c5,c6,c7,c8,sick,offset,mjs,filter
    dim as short a,b,c,lastinv,set,tlen,cx,cy
    dim as string text,key
    dim inv(256) as _items
    dim invn(256) as short
    dim cargo(12) as string
    dim cc(12) as short
    
    set__color( 0,0)
    cls
    if heading=0 then textbox("{15}Name: {11}"&player.desig &"{15} Type:{11}" &player.h_desig,1,0,40)
    textbox(shipstatsblock,1,2,40)
    'Weapons
    c=player.h_maxweaponslot
    locate 7,3
    set__color( 15,0)
    draw string (3*_fw2,7*_fh2), "Weapons:",,font2,custom,@_col
    set__color( 11,0)
    for a=1 to c
        if player.weapons(a).dam>0 then
            set__color( 15,0)
            draw string (3*_fw2,(8+b)*_fh2), player.weapons(a).desig ,,font2,custom,@_col
            set__color( 11,0)
            if player.weapons(a).ammomax<=0 then draw string (3*_fw2,(8+b+1)*_fh2) ," R:"& player.weapons(a).range &"/" & player.weapons(a).range*2 &"/" & player.weapons(a).range*3 &" D:"&player.weapons(a).dam ,,font2,custom,@_col
            if player.weapons(a).ammomax>0 then draw string (3*_fw2,(8+b+1)*_fh2) ," R:"& player.weapons(a).range &"/" & player.weapons(a).range*2 &"/" & player.weapons(a).range*3 &" D:"&player.weapons(a).dam &" A:"&player.weapons(a).ammomax &"/" &player.weapons(a).ammo &"  ",,font2,custom,@_col
            b=b+2
        else
            locate 8+b,4
            set__color( 15,0)
            if player.weapons(a).desig="" then
            draw string (3*_fw2,(8+b+1)*_fh2), "-Empty-",,font2,custom,@_col
        else
            draw string (3*_fw2,(8+b+1)*_fh2), player.weapons(a).desig,,font2,custom,@_col
            endif
            b=b+1
        endif
    next
    'Cargo
    b=b-1
    text=cargobay("/")
    a=0
    locate 17,3
    set__color( 15,0)
    draw string (3*_fw2,16*_fh2), "Cargo:",,font2,custom,@_col
    set__color( 11,0)
    cargo(1)="Empty"
    cargo(2)="Food, bought at"
    cargo(3)="Basic goods, bought at"
    cargo(4)="Tech goods, bought at"
    cargo(5)="Luxury goods, bought at"
    cargo(6)="Weapons, bought at"
    cargo(7)="Narcotics, bought at"
    cargo(8)="Hightech, bought at"
    cargo(9)="Computers, bought at"
    cargo(10)="Fuel, bought at"
    cargo(11)="Mysterious box"
    cargo(12)="TT Contract Cargo"
    for c=1 to 10
        if player.cargo(c).x=1 then cc(player.cargo(c).x)=cc(player.cargo(c).x)+1  
        if player.cargo(c).x>9 then cc(player.cargo(c).x)=cc(player.cargo(c).x)+1  
            
        if player.cargo(c).x>1 and player.cargo(c).x<=9 then 
            cc(player.cargo(c).x)=cc(player.cargo(c).x)+1  
            cargo(player.cargo(c).x)=cargo(player.cargo(c).x)&" "&player.cargo(c).y &", " 
        endif
    next
    for c=1 to 11
        if cc(c)>0 then 
            if c>1 and c<7 then
                cargo(c)=left(cargo(c),len(cargo(c))-2)&"."
            endif    
            draw string (0,(16+c)*_fh2), cc(c)&" x "&cargo(c),,font2,custom,@_col
        endif
    next
    
    c=textbox(crewblock,(_mwx/2)*_fw2/_fw1+4,2,22)
    
    c=textbox(listartifacts,(_mwx)*_fw2/_fw1+4,2,22)
    
    c=c+2
    if heading=0 then
        lastinv=getitemlist(inv(),invn()) 
        set__color( 15,0)
        draw string (((_mwx)*_fw2/_fw1+4)*_fw1,(2+c+a)*_fh2) ,"Equipment("&lastinv & ", " &credits(equipment_value) &  " Cr.):",,font2,custom,@_col
        set__color( 11,0)
        do
            set__color( 15,0)
            draw string (((_mwx)*_fw2/_fw1+4)*_fw1,(2+c+a)*_fh2) ,"Equipment("&lastinv & ", " &credits(equipment_value) &  " Cr.):",,font2,custom,@_col
            set__color( 11,0)
            'for a=0 to _lines-c     
            a=0
            b=0
            do 
                b+=1
                'dprint checkitemfilter(inv(b+offset).ty,filter) &":"&inv(b+offset).ty
                if checkitemfilter(inv(b+offset).ty,filter)=1 then
                    a+=1
                    set__color( 0,0)
                    draw string (((_mwx)*_fw2/_fw1+4)*_fw1,(3+c+a)*_fh2) ,space(30),,font2,custom,@_col
                    set__color( 11,0)
                    if invn(b+offset)>1 then
                        draw string (((_mwx)*_fw2/_fw1+4)*_fw1,(3+c+a)*_fh2) , invn(b+offset)&" "&left(inv(b+offset).desigp,27),,font2,custom,@_col
                    else
                        if invn(b+offset)=1 then draw string (((_mwx)*_fw2/_fw1+4)*_fw1,(3+c+a)*_fh2) , left(inv(b+offset).desig,27),,font2,custom,@_col
                    endif
                endif
                'dprint _lines-c &":"&a &":"& b &":" &lastinv
            loop until a>=_lines-c or b>=lastinv 
            
            draw string (((_mwx)*_fw2/_fw1+20)*_fw1,_lines*_fh2) , " ",,font2,custom,@_col
            if lastinv>_lines-c and offset+(_lines-c)<=lastinv then                    
                set__color( 14,0)
                draw string (((_mwx)*_fw2/_fw1+20)*_fw1,_lines*_fh2) , chr(25),,font2,custom,@_col
            endif
            draw string (((_mwx)*_fw2/_fw1+20)*_fw1,(2+c)*_fh2), " ",,font2,custom,@_col
            if offset>0 then    
                set__color( 14,0)
                draw string (((_mwx)*_fw2/_fw1+20)*_fw1,(2+c)*_fh2), chr(24),,font2,custom,@_col
            endif
            key=keyin(key_filter &"q",1)
            if keyminus(key) then offset=offset-1
            if keyplus(key) then offset=offset+1
            if key=key_filter then filter=itemfilter
            if offset<0 then offset=0
            if offset>33 then offset=33
        loop until key=key__esc or key=" "
        
    endif
    cls
    return 0
end function



function display_planetmap(a as short,osx as short,bg as byte) as short
    dim x as short
    dim y as short
    dim b as short
    dim x2 as short
    dim debug as byte
    if planets(a).depth>0 then
        if osx<0 then osx=0
        if osx>60-_mwx then osx=60-_mwx
    endif
    if _mwx=60 then osx=0
    
    for x=_mwx to 0 step-1
        for y=0 to 20
            x2=x+osx
            if x2>60 then x2=x2-61
            if x2<0 then x2=x2+61
            if planetmap(x2,y,a)>0 then
                dtile(x,y,tiles(planetmap(x2,y,a)),bg)
            endif
        next
    next
'    for x=_mwx to 0 step-1
'        x2=x+osx
'        if x2>60 then x2=x2-61
'        if x2<0 then x2=x2+61
'        set__color( 15,0
'        draw string (x*_tix,22*_tiy),""&x2
'    next
    
    for b=0 to lastportal
        x=portal(b).from.x-osx
        if x<0 then x+=61
        if x>60 then x-=61
        if x>=0 and x<=_mwx then 
            if portal(b).from.m=a and portal(b).discovered=1 and portal(b).oneway<2 then
                if _tiles=0 then
                    put ((x)*_tix,portal(b).from.y*_tiy),gtiles(gt_no(portal(b).ti_no)),trans
                    if debug=1 then draw string(portal(b).from.x*_fw1,portal(b).from.y*_fh1),""&portal(b).ti_no,,Font2,custom,@_col
                else
                    set__color( portal(b).col,0)
                    draw string(portal(b).from.x*_fw1,portal(b).from.y*_fh1),chr(portal(b).tile),,Font1,custom,@_col
                endif
            endif
        endif
        x=portal(b).dest.x-osx
        if x<0 then x+=61
        if x>60 then x-=61
        
        if x>=0 and x<=_mwx then 
            if portal(b).oneway=0 and portal(b).dest.m=a and portal(b).discovered=1 then
                if _tiles=0 then
                    put ((x)*_tix,portal(b).dest.y*_tiy),gtiles(gt_no(portal(b).ti_no)),trans
                else
                    set__color( portal(b).col,0)
                    draw string(portal(b).dest.x*_fw1,portal(b).dest.y*_fh1),chr(portal(b).tile),,Font1,custom,@_col
                endif
            endif
        endif
    next
    for b=1 to lastitem
        if debug=1 and item(b).w.m=a then dprint b &":"&item(b).w.x-osx &"."&item(b).w.x &"_"& osx
        x=item(b).w.x-osx
        if x<0 then x+=61
        if x>60 then x-=61
        if x>=0 and x<=_mwx then
            if item(b).w.m=a and item(b).w.s=0 and item(b).w.p=0 and item(b).discovered=1 then
                if _tiles=0 then
                    put (x*_tix,item(b).w.y*_tiy),gtiles(gt_no(item(b).ti_no)),alpha,196
                    if debug=1 then draw string ((item(b).w.x-osx)*_tix,item(b).w.y*_tiy),""& b,,Font1,custom,@_col
                else            
                    if item(a).ty<>99 then
                        set__color( item(b).col,item(b).bgcol)
                        draw string(item(b).w.x*_fw1,item(b).w.y*_fh1),item(b).icon,,Font1,custom,@_col
                    else
                        set__color( rnd_range(1,15),0)
                        draw string(item(b).w.x*_fw1,item(b).w.y*_fh1),item(b).icon,,Font1,custom,@_col
                    endif
                endif
            endif
        endif
    next
    if debug=2 and lastapwp>0 then
        for b=0 to lastapwp
            if apwaypoints(b).x-osx>=0 and apwaypoints(b).x-osx<=_mwx then
                set__color( 11,0)
                draw string((apwaypoints(b).x-osx)*_tix,apwaypoints(b).y*_tiy),""& b,,Font1,custom,@_col
                
            endif
        next
    endif
    
    if debugvacuum=1 then
        for x=0 to 60
            for y=0 to 20
                set__color(c_gre,0)
                if vacuum(x,y)=1 then set__color(c_red,0) 
                pset(x,y)
            next
        next
        
    endif
    return 0
end function

function textbox(text as string,x as short,y as short,w as short, fg as short=11, bg as short=0) as short
    dim as short lastspace,tlen,p,wcount,lcount,xw,a
    dim words(1023) as string
    dim addt as string
    addt=text
    'if len(text)<=w then addt(0)=text
    for p=0 to len(text)
        if mid(text,p,1)="{" or mid(text,p,1)="|" then wcount+=1
        words(wcount)=words(wcount)&mid(text,p,1)
        if mid(text,p,1)=" " or mid(text,p,1)="|" or  mid(text,p,1)="}" then wcount+=1
    next
    if words(wcount)<>"|" then 
        wcount+=1
        words(wcount)="|"
    endif
    set__color( fg,bg)
    for p=0 to wcount
        if words(p)="|" then 
            draw string((x)*_fw1+xw*_fw2,y*_fh1+lcount*_fh2),space(w-xw),,font2,custom,@_col
            lcount=lcount+1
            xw=0
        endif
        if Left(trim(words(p)),1)="{" and Right(trim(words(p)),1)="}" then
            set__color( numfromstr(words(p)),bg)
        endif
        if words(p)<>"|" and not(Left(trim(words(p)),1)="{" and Right(trim(words(p)),1)="}") then
            if xw+len(words(p))>w then 
                draw string((x)*_fw1+xw*_fw2,y*_fh1+lcount*_fh2),space(w-xw),,font2,custom,@_col
                lcount=lcount+1
                xw=0
            endif
            draw string((x)*_fw1+xw*_fw2,y*_fh1+lcount*_fh2),words(p),,font2,custom,@_col
            xw=xw+len(words(p))
            
        endif
        if lcount*_fh2+y*_fh1>_screeny-_fh1 then
            set__color( 14,0)
            draw string(x*_fw1+w*_fw2-_fw2,_screeny-_fh2),chr(25),,font2,custom,@_col
            no_key=keyin
            for a=0 to lcount
                draw string((x)*_fw1,y*_fh1+a*_fh2),space(w),,font2,custom,@_col
            next    
            lcount=0
        endif
    next
    text=addt
    return lcount
end function

function locEOL() as _cords
    'puts cursor at end of last displayline
    dim as short y,x,a,winh,firstline
    dim as _cords p
    winh=fix((_screeny-_fh1*22)/_fh2)-1
    do
        firstline+=1
    loop until firstline*_fh2>=22*_fh1
    
    y=firstline+winh
    for a=firstline+winh to firstline step -1
        if displaytext(a+1)="" then y=a
    next
    x=len(displaytext(y))+1
    p.x=x
    p.y=y
    return p
end function

function scrollup(b as short) as short
    dim as short a,c
    for c=0 to b
        for a=0 to 254
            displaytext(a)=displaytext(a+1)
            dtextcol(a)=dtextcol(a+1)
        next
        displaytext(255)=""
        dtextcol(255)=11
    next
    return 0
end function

function dprint(t as string, col as short=11) as short
    dim as short a,b,c,delay
    dim text as string
    dim wtext as string
    'static offset as short
    dim tlen as short
    'dim addt(64) as string
    dim lastspace as short
    dim key as string
    dim as short winw,winh
    dim firstline as byte
    dim words(4064) as string
    static curline as single
    static lastcalled as double
    static lastmessage as string
    static lastmessagecount as short
    firstline=fix((22*_fh1)/_fh2)
    winw=fix(((_fw1*_mwx+1))/_fw2)
    winh=fix((_screeny-_fh1*22-_fh2)/_fh2)
    if t<>"" then
'    firstline=0
'    do
'        firstline+=1
'    loop until firstline*_fh2>=22*_fh1
'    
    if _fh1=_fh2 then
        firstline=22
        winh=_lines-22
    endif
    curline=locEOL.y+1
    for a=0 to len(t)
        if mid(t,a,1)<>"|" then text=text & mid(t,a,1)
    next
    if text<>"" and len(text)<winw-4 then
        if lastmessage=t then
            a=curline-1
            lastmessagecount+=1
            if len(displaytext(a))<winw-4 then
                displaytext(a)=text &"(x"&lastmessagecount &")"
                t=""
            else
                displaytext(a)=text
                displaytext(a+1)="(x"&lastmessagecount &")"
                t=""
            endif
            text=""
        else
            lastmessage=t
            lastmessagecount=1
        endif
    endif
    if lastcalled=0 then lastcalled=timer
    if delay=1 and t<>"" then
        do
        loop until timer>lastcalled+.05
    endif
    lastcalled=timer
    
    'draw string (61*_fw1,firstline*_fh2),"*",,font1,custom,@_col
    'draw string (61*_fw1,(firstline+winh)*_fh2),"*",,font1,custom,@_col
    'find offset
    'if offset=0 then offset=firstline
    
    if text<>"" then
        while displaytext(curline)<>"" 
            curline+=1
        wend
        for a=0 to len(text)
            words(b)=words(b)&mid(text,a,1)
            if mid(text,a,1)=" " then b+=1
        next
        for a=0 to b
            if instr(ucase(words(a)),"\C")>0 then
                words(a)="Ctrl-"&right(trim(words(a)),1) &" "
            endif
        next
        for a=0 to b
            if len(displaytext(curline+tlen))+len(words(a))>=winw then
                displaytext(curline+tlen)=trim(displaytext(curline+tlen))                
                tlen+=1
            endif
            displaytext(curline+tlen)=displaytext(curline+tlen)&words(a)
            dtextcol(curline+tlen)=col
        next
        
        if curline+tlen>firstline+winh then            
            if tlen<winh then
                scrollup(tlen-1)
            else
                do
                    scrollup(winh-2)
                    for b=firstline to firstline+winh
                        set__color( 0,0)
                        'draw string(0,(b-firstline)*_fh2+22*_fh1), space(winw),,font2,custom,@_col
                        draw string(0,b*_fh2), space(winw),,font2,custom,@_col
                        set__color( dtextcol(b),0)
                        draw string(0,b*_fh2), displaytext(b),,font2,custom,@_col
                        'draw string(0,(b-firstline)*_fh2+22*_fh1), displaytext(b),,font2,custom,@_col
                    next
                    set__color( 14,1)
                    if displaytext(firstline+winh+1)<>"" then
                        draw string((winw+1)*_fw2,_screeny-_fh2), chr(25),,font2,custom,@_col
                        no_key=keyin
                    endif
                loop until displaytext(_textlines+1)=""
            endif
        else
            if curline=firstline+winh then scrollup(0)
        endif
        while displaytext(_textlines+1)<>""
            scrollup(0)
            wend
        endif
    endif
    for b=firstline to firstline+winh
        set__color( 0,0)
        'draw string(0,(b-firstline)*_fh2+22*_fh1), space(winw),,font2,custom,@_col
        draw string(0,b*_fh2), space(winw),,font2,custom,@_col
        set__color( dtextcol(b),0)
        'draw string(0,(b-firstline)*_fh2+22*_fh1), displaytext(b),,font2,custom,@_col
        draw string(0,b*_fh2), displaytext(b),,font2,custom,@_col
    next
    locate 24,1
    set__color( 11,0)
    return 0
end function    

function getrandomsystem(unique as short=0,gascloud as short=0,disweight as short=0) as short 'Returns a random system. If unique=1 then specialplanets are possible
    dim as short a,b,c,p,u,ad,debug,cc,f
    dim pot(laststar*50) as short
    'debug=1
    
    if debug=1 then
        f=freefile
        open "getrandsystem.csv" for append as #f
    endif
    
    for a=0 to laststar
        if map(a).discovered=0 and map(a).spec<8 then
            ad=0
            if unique=0 then
                for p=1 to 9
                    for u=0 to lastspecial
                        if map(a).planets(p)=specialplanet(u) then ad=1
                    next
                next
            endif
            if spacemap(map(a).c.x,map(a).c.y)<>0 then cc+=1
            if gascloud=1 and (spacemap(map(a).c.x,map(a).c.y)=0 or abs(spacemap(map(a).c.x,map(a).c.y))>6) then ad=1
            if ad=0 then
                if disweight=1 then 'Weigh for distance
                    cc=1+disnbase(map(a).c)*disnbase(map(a).c)/10
                else
                    cc=1
                endif
                if debug=1 then print #f,a &";"& cc &";"& disnbase(map(a).c)
                for p=1 to cc
                    b=b+1
                    pot(b)=a
                    'print "B";b;":";
                next
            endif
        endif
    next
    if debug=1 then
        print #f,"+++++"
        close #f
    endif
        
    if b>0 then 
        c=pot(rnd_range(1,b))
    else 
        c=-1
    endif
    return c
end function 


function getrandomplanet(s as short) as short
    dim pot(10) as short
    dim as short a,b,c
    if s>=0 and s<=laststar then
        for a=1 to 9
            if map(s).planets(a)>0 then
                b=b+1
                pot(b)=map(s).planets(a)
                
            endif
        next
        if b<=0 then 
            c=-1
        else 
            c=pot(rnd_range(1,b))
        endif
    else
        c=-1
    endif
    return c
end function

function getsystem(player as _ship) as short
    dim a as short
    dim b as short
    b=-1
    for a=0 to laststar
        if player.c.x=map(a).c.x and player.c.y=map(a).c.y then b=a
    next
    return b
end function


function getclass(a as short=0) as string
    dim cl as string
    if a=0 then
        if player.hulltype<=50 then cl="HC"
        if player.hulltype<=40 then cl="C"
        if player.hulltype<=30 then cl="LC"
        if player.hulltype<=20 then cl="HS"
        if player.hulltype<=10 then cl="S"
    else        
        if player.hulltype<=50 then cl="Heavy Cruiser"
        if player.hulltype<=40 then cl="Cruiser"
        if player.hulltype<=30 then cl="Light Cruiser"
        if player.hulltype<=20 then cl="Heavy Scout"
        if player.hulltype<=10 then cl="Scout"
    endif
    return cl
end function

function getmonster(enemy() as _monster, byref lastenemy as short) as short
    dim as short d,e,c
    d=0
    for c=1 to lastenemy 'find dead that doesnt respawn
        if enemy(c).respawns=0 and enemy(c).hp<=0 then d=c
    next
    if d=0 then
        lastenemy=lastenemy+1
        d=lastenemy                            
        if d>128 then 
            lastenemy=128
            e=0
            do 
                e=e+1
                d=rnd_range(1,25)
            loop until enemy(d).hp<=0 or e=50
        endif
    endif
    return d
end function

'function getshipweapon() as short
'    dim as short a,b,c
'    dim p(7) as short
'    dim t as string
'    t="Chose weapon/"
'    for a=1 to 5
'        if player.weapons(a).dam>0 then
'            b=b+1
'            p(b)=a
'            t=t &player.weapons(a).desig & "/"
'        endif
'    next
'    b=b+1
'    p(b)=-1
'    t=t &"Cancel"
'    c=b-1
'    if b>1 then c=p(menu(t))
'    return c
'end function


function sysfrommap(a as short)as short
    '
    ' returns the systems number of a special planet
    '
    dim planet as short
    dim as short b,c,d
    for b=0 to laststar
        for c=1 to 9
            if map(b).planets(c)=a then planet=b
        next
    next
    return planet
end function

function orbitfrommap(a as short) as short
    dim as short orbit,sys,b
    sys=sysfrommap(a)
    if sys<>0 then
        for b=1 to 9
            if map(sys).planets(b)=a then return b
        next
    endif
    return -1
end function

function changetile(x as short,y as short,m as short,t as short) as short
    if planetmap(x,y,m)<0 then 
        planetmap(x,y,m)=abs(t)*-1
    else
        planetmap(x,y,m)=abs(t)
    endif
    return 0
end function

function copytile (byval a as short) as _tile
    dim r as _tile
    if a<0 then a=-a
    r.no=tiles(a).no 
    r.tile=tiles(a).tile
    r.desc=tiles(a).desc 
    r.bgcol=tiles(a).bgcol  
    r.col=tiles(a).col  
    r.seetru=tiles(a).seetru 
    r.walktru=tiles(a).walktru 
    r.firetru=tiles(a).firetru 
    r.shootable=tiles(a).shootable
    r.dr=tiles(a).dr
    r.hp=tiles(a).hp
    r.turnsinto=tiles(a).turnsinto
    r.succt=tiles(a).succt
    r.failt=tiles(a).failt
    r.spawnson=tiles(a).spawnson
    r.spawnswhat=tiles(a).spawnswhat
    r.spawnsmax=tiles(a).spawnsmax
    r.gives=tiles(a).gives
    return r
end function
    
function chr850(c as short) as string
    dim c2 as short
    c2=c
    if _savescreenshots=1 then
        if c>127 then c2=43
        if c=179 or c=186 then c2=124 '|
        if c=196 or c=205 then c2=45 '_
        if c=180 or c=195 then c2=43 '+
    endif
    return chr(c2)
end function

