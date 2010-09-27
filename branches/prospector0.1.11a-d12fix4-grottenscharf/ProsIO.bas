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

function maxsecurity() as short
    dim as short b,total
    total=player.h_maxcrew+player.crewpod+player.cryo-5
    for b=6 to 128
        if crew(b).hp>0 then total-=1
    next
    return total
end function

function skillcheck(targetnumber as short,skill as short, modifier as short) as short
    'skill
    '1 Pilot
    '2 Gunner
    '3 Science
    '4 Doctor
    dim as short skillvalue
    if rnd_range(1,6)+rnd_range(1,6)+skillvalue+modifier>targetnumber then
        return -1
    else
        return 0
    endif
end function

function addtalent(cr as short, ta as short, value as single) as single
    dim total as short
    if cr>0 then
        if crew(cr).hp>0 and crew(cr).talents(ta)>0 and ta=10 then
            if player.tactic>0 then return crew(cr).talents(ta)
            if player.tactic<0 then return -crew(cr).talents(ta)
            return 0
        endif
        if crew(cr).hp>0 and crew(cr).talents(ta)>0 then return value*crew(cr).talents(ta)
    else
        value=0
        for cr=1 to 128
            if crew(cr).hp>0 and crew(cr).onship=0 then 
                total+=1
                value=value+crew(cr).talents(ta)
                if ta=24 then value=value+crew(cr).augment(4)/5
            endif
        next
        if total=0 then return 0
        value=value/total
        return value
    endif
    return 0
end function
    
function changemoral(value as short, where as short) as short
    dim a as short
    for a=2 to 128
        if crew(a).hp>0 and crew(a).onship=where then crew(a).morale=crew(a).morale+value
    next
    return 0
end function


function showteam(from as short, r as short=0) as short
    'Show all awayteam, member's skills, armor, melee weapons and fire weapons
    dim as short b,bg,last,a,sit,cl,cl2,prob
    dim dummy as _monster
    dim p as short
    dim offset as short
    dim n as string
    dim skills as string
    dim augments as string
    
    for a=1 to lastitem
        for b=1 to lastitem-1
            if a<>b and item(b).uid=item(a).uid then
                destroyitem(b)
                b-=1
            endif
        next
    next
    
    for b=1 to 128
        if crew(b).hpmax>0 then last=b
    next
    p=1
    no_key=""
    equip_awayteam(player,dummy,0)
        
    do
        cls
        color 11,0
        if no_key=key_enter then
            if r=0 then
                if from=0 then
                    if p>1 then
                        if crew(p).onship=0 then 
                            crew(p).onship=1
                        else
                            crew(p).onship=0
                        endif
                    else
                        locate 22,1
                        color 14,0
                        print "The captain must stay in the awayteam."
                        locate 1,1
                    endif
                else
                    locate 22,1
                    color 14,0
                    print "You need to be at the ship to reassign."
                    locate 1,1
                endif
            endif
            if r=1 then return p
                
        endif
        'Set prefered weapons for each awayteam member. lrweap is fire weapons, ccweap is melee weapons.
        if no_key="s" then
            sit=getitem() 'if getitem() returns nothing then sit=-1
            a=0
            cl=1
            if sit>=0 then
                do 'find last item of same description
                    'search last item that no one is equiped
                    if item(a).desig=item(sit).desig then
                        if item(a).w.s=-2 or item(a).w.s=-1 then
                            sit=a
                            if item(sit).w.s=-1 then a=1+lastitem
                        endif
                    endif
                    a+=1
                loop until a>lastitem
                'dprint "debug: found last item in inventory:" &item(sit).w.s
                'sleep 1000
                'sit is last item with item(sit).desig in inventory
                
                'search for items no one prefers if it is equipped
                cl2=0
                b=0
                prob=2 '1/prob probability of choosing next crew that prefer item
                if item(sit).w.s=-2 then 'if someone is equipped with sit search him
                    for a=0 to sit
                        if item(a).desig=item(sit).desig and item(a).w.s=-2 then
                            b+=1 'number of same items
                            sit=a
                            'dprint "Debug: same items: " +str(b)
                            'sleep 1000
                        endif
                    next
                    a=sit
                    'check items backwards to find item no one prefers
                    do
                        if item(a).desig=item(sit).desig and item(a).w.s=-2 then
                            cl=last 'checks crew members prefered items backwards for last crew with item
                            b-=1 'found an item
                            do
                                'dprint "debug: test item number:"&a 
                                if (crew(cl).pref_lrweap=item(a).uid or crew(cl).pref_ccweap=item(a).uid or crew(cl).pref_armor=item(a).uid) then
                                    'number of same items
                                    if cl2=0 then
                                        sit=a
                                        prob=2
                                        cl2=cl
                                        'dprint "Debug: Found crew " &cl &" with same item: " +str(a)
                                        'sleep
                                    elseif  crew(cl).hpmax<crew(cl2).hpmax then
                                        sit=a
                                        prob=2
                                        cl2=cl
                                        'dprint "Debug: Found crew " &cl &" with same item: " +str(a)
                                        'sleep
                                    elseif  crew(cl).hpmax=crew(cl2).hpmax then
                                        'dprint "Debug: Found crew " &cl &" with item same hp, item: " +str(a)
                                        'sleep
                                        if rnd_range(1,prob)=1 then
                                        'decide if crew is unnequiped when two have same hp
                                        '1/prob probability of choosing next crew that prefer item
                                            cl2=cl
                                            sit=a
                                            prob+=1
                                        endif
                                    endif
                                    cl=-1
                                endif
                                cl-=1
                            loop until cl<1
                            'dprint "debug: item number: " &sit &"  last crew number test: " &cl &" prob: " &prob
                            if cl=0 then 'no one prefers item a
                                'dprint "Debug: Found item no one prefers: " &a
                                'sleep
                                cl2=-1 'no need for crew member with item
                                sit=a 'no one prefers then set item
                            endif
                        endif
                        a-=1
                    loop until a<=-1 or b=0 or cl2<0
                endif
                'select case for member with least health that prefer this item and ask player
                if cl2>0 then
                    cl=cl2
                    a=sit
                    if sit>=0 then
                        if item(sit).w.s=-2 and p<>cl and (crew(cl).pref_lrweap=item(sit).uid or crew(cl).pref_ccweap=item(sit).uid or crew(cl).pref_armor=item(sit).uid) then
                            'dprint "Debug: Find crew " &cl &" type with item same items: " +str(a)
                            'sleep
                            select case crew(cl).typ
                            case 1 
                                if not askyn("This " &item(sit).desig &" belongs to Captain " &crew(cl).n &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 2
                                if not askyn("This " &item(sit).desig &" belongs to Pilot " &crew(cl).n &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 3 
                                if not askyn("This " &item(sit).desig &" belongs to Gunner " &crew(cl).n &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 4 
                                if crew(cl).icon="T" then
                                    if not askyn("This " &item(sit).desig &" belongs to Science officer " &crew(cl).n &", the wise tree being, crew no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                                else 
                                    if not askyn("This " &item(sit).desig &" belongs to Science officer " &crew(cl).n &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                                endif
                            case 5
                                if not askyn("This " &item(sit).desig &" belongs to Doctor " &crew(cl).n &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 6
                                if not askyn("This " &item(sit).desig &" is used by Rookie " &crew(cl).n &", our security crew member no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 7 
                                if not askyn("This " &item(sit).desig &" is used by Veteran security officer " &crew(cl).n &", our security crew member no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 8
                                if not askyn("This " &item(sit).desig &" is used by Elite security officer " &crew(cl).n &", our security crew member no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 9
                                if not askyn("This " &item(sit).desig &" is used by " &crew(cl).n &", the insectoid, our security crew member no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 10
                                if not askyn("This " &item(sit).desig &" is used by " &crew(cl).n &", the strong cephalopod, our security crew member no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 11
                                if not askyn("This " &item(sit).desig &" is used by the " &crew(cl).n &", called 'no." &cl &"'. Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 12
                                if not askyn("This " &item(sit).desig &" is used by the " &crew(cl).n &", called 'no." &cl &"'. Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case 13
                                if not askyn("This " &item(sit).desig &" is used by the " &crew(cl).n &", called 'no." &cl &"'. Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            case else  
                                if item(sit).w.s=-2 and askyn("This " &item(sit).desig &" is used by " &crew(cl).n &" [hp:" &crew(cl).hpmax &", xp:" &crew(cl).xp &"], our crew member no." &cl &". Do you want to reassign it to another crew member? (y/n)") then sit=-1
                            end select
                            if sit>=0 then dprint "Confirmed equipment reassigning."                                
                            dprint ""
                            if sit>=0 then
                                if crew(cl).pref_lrweap=item(sit).uid then crew(cl).pref_lrweap=0
                                if crew(cl).pref_ccweap=item(sit).uid then crew(cl).pref_ccweap=0
                                if crew(cl).pref_armor=item(sit).uid then crew(cl).pref_armor=0
                            endif
'                            if sit<0 then
'                                if askyn("Add crew in queue for a " &item(a).desig &" (y/n)") then sit=a
'                                'dprint "Adding to queue makes the crewmember prefer this item, if he is upper the list, he gets prefered items before others."
'                            endif
                            if sit<0 then
                                displaytext(25)=""
                                dprint ""
                                dprint "Equipment reassigning cancelled."
                            endif
                        endif
                    endif
                endif
            endif
            
            if sit>=0 then
                if item(sit).ty=2 then 
                    crew(p).pref_lrweap=item(sit).uid
                endif
                if item(sit).ty=4 then 
                    crew(p).pref_ccweap=item(sit).uid
                endif
                if item(sit).ty=3 then 
                    crew(p).pref_armor=item(sit).uid
                endif
                equip_awayteam(player,dummy,0)
            endif
        endif
        
        if no_key="c" then
            crew(p).pref_lrweap=0
            crew(p).pref_ccweap=0
            crew(p).pref_armor=0
            equip_awayteam(player,dummy,0)
        endif
        
        cls
        
        for b=1 to 8
            if b=p+offset then
                bg=5
            else
                bg=0
            endif
            if b-offset>0 then  
                if crew(b-offset).hpmax>0 then
                    skills=""
                    augments=""
                    for a=1 to 25
                        if crew(b-offset).talents(a)>0 then 
                            if skills<>"" then 
                                skills=skills &", "&talent_desig(a)&"("&crew(b-offset).talents(a)&")"
                            else
                                skills=talent_desig(a)&"("&crew(b-offset).talents(a)&")"
                            endif
                        endif
                    next
                    
                    if crew(b-offset).augment(1)>0 then augments=augments &"Targeting "
                    if crew(b-offset).augment(2)>0 then augments=augments &"Muscle Enh. "
                    if crew(b-offset).augment(3)>0 then augments=augments &"Imp. Lungs "
                    if crew(b-offset).augment(4)>0 then augments=augments &"Speed Enh. "
                    if crew(b-offset).augment(5)>0 then augments=augments &"Exosceleton "
                    if crew(b-offset).augment(6)>0 then augments=augments &"Imp. Metabolism "
                    
                    if skills<>"" then skills=skills &" "
                    color 15,bg
                    if b-offset>9 then
                        print b-offset;" ";
                    else
                        print " ";b-offset;" ";
                    endif
                    if crew(b-offset).hp>0 then
                        if b-offset>5 then
                            color 10,bg
                            print crew(b-offset).icon;
                        else
                            if b-offset=1 then print "Captain";
                            if b-offset=2 then print "Pilot  ";
                            if b-offset=3 then print "Gunner ";
                            if b-offset=4 then print "Science";
                            if b-offset=5 then print "Doctor ";
                        endif
                    else
                        color 12,0
                        print "X";
                    endif
                    
                    color 15,bg
                    if crew(b-offset).hp=0 then color 12,bg
                    if crew(b-offset).hp<crew(b-offset).hpmax then color 14,bg
                    if crew(b-offset).hp=crew(b-offset).hpmax then color 10,bg
                    print " ";crew(b-offset).hpmax;
                    color 15,bg
                    print "/";
                    if crew(b-offset).hp=0 then color 12,bg
                    if crew(b-offset).hp<crew(b-offset).hpmax then color 14,bg
                    if crew(b-offset).hp=crew(b-offset).hpmax then color 10,bg
                    print crew(b-offset).hp;
                    color 15,bg
                    print " ";crew(b-offset).n;
                    if crew(b-offset).onship=1 and crew(b-offset).hp>0 then
                        color 14,bg
                        print "  On ship ";
                    endif
                    if crew(b-offset).onship=0 and crew(b-offset).hp>0 then
                        color 10,bg
                        print " Awayteam ";
                    endif
                    if crew(b-offset).hp<=0 then
                        color 12,bg
                        print " Dead ";
                    endif
                    color 15,bg
                    if crew(b-offset).xp>=0 then 
                        print " XP:" &crew(b-offset).xp;
                    else
                        print " XP: -";
                    endif
                    print space(70-pos)
                    color 15,bg
                    print "   ";
                    if crew(b-offset).armo>0 then 
                        color 15,bg
                        if crew(b-offset).pref_armor>0 then
                            print "*";
                        else
                            print " ";
                        endif
                        print trim(item(crew(b-offset).armo).desig);", ";
                    else
                        color 14,bg
                        print " None,";
                    endif
                    if crew(b-offset).weap>0 then 
                        color 15,bg
                        if crew(b-offset).pref_lrweap>0 then
                            print "*";
                        else
                            print " ";
                        endif
                        print trim(item(crew(b-offset).weap).desig);", ";
                    else
                        color 14,bg
                        print " None,";
                    endif
                    if crew(b-offset).blad>0 then 
                        color 15,bg
                        if crew(b-offset).pref_ccweap>0 then
                            print "*";
                        else
                            print " ";
                        endif
                        print trim(item(crew(b-offset).blad).desig);" ";
                    else
                        color 14,bg
                        print " None";
                    endif
                    color 11,bg
                    if crew(b-offset).jp>0 then print " Jetpack";
                    print space(70-pos)
                    
                    color 15,bg
                    print "   ";
                    print skills;
                    print augments;
                    if crew(b-offset).disease>0 then
                        color 14,bg
                        print "Suffers from "&trim(disease(crew(b-offset).disease).desig);
                    endif
                    print space(70-pos)
                    
                    color 11,bg
                endif
            endif
        next
        color 11,0
        locate 25,1
        if r=0 then 
            print key_rename &" rename a member,";
            if from=0 then print "enter add/remove from awaytem,";
            print "s set Item, c clear, esc exit";
        endif
        if r=1 then print "Enter to chose crewmember";
        no_key=keyin(,,1)
        if keyplus(no_key) or getdirection(no_key)=2 then p+=1
        if keyminus(no_key) or getdirection(no_key)=8 then p-=1
        if no_key=key_rename then
            if p<6 then
                n=gettext(18,(p-1+offset)*3,16,n)
            else
                n=gettext(12,(p-1+offset)*3,16,n)
            endif
            if n<>"" then crew(p).n=n
            n=""
        endif
        if p<1 then p=last
        if p>last then p=1
        if p+offset>8 then offset=8-p
        if p+offset<1 then offset=1-p
        
        
        
       
    loop until no_key=key_esc or no_key=" "
    cls
    return 0
end function

function removemember(n as short, f as short) as short
    dim as short a,s,todo
    
    if f=0 then s=6
    if f=1 then s=2
    for a=128 to s step-1
        if crew(a).hp>0 and todo<n then
            crew(a).hp=0
            todo+=1
        endif
    next
    return 0
end function


function addmember(a as short) as short
    dim as short slot,b,f,c,cc
    dim _del as _crewmember
    dim as string n(200,1)
    dim as short ln(1)
    f=freefile
    open "data\crewnames.txt" for input as #f
    do
        ln(cc)+=1
        line input #f,n(ln(cc),cc)
        if n(ln(cc),cc)="####" then
            ln(0)-=1
            cc=1
        endif
        
    loop until eof(f) or ln(0)>=199 or ln(1)>=199
    close #f
    'find empty slot
    for b=128 to 6 step -1
        if crew(b).hp<=0 then slot=b
    next
    if a<6 then slot=a
    if slot>0 then
        
        crew(slot)=_del
        if rnd_range(1,100)<80 then
            crew(slot).n=n((rnd_range(1,ln(1))),1)&" "&n((rnd_range(1,ln(0))),0)
        else
            crew(slot).n=n((rnd_range(1,ln(1))),1)&" "&CHR(rnd_range(65,87))&". "&n((rnd_range(1,ln(0))),0)
        endif
        crew(slot).morale=100+(Wage-10)^3*(5/100)
        'crew(slot).talents(rnd_range(1,25))=1
        'crew(slot).talents(rnd_range(1,25))=1
        'crew(slot).talents(rnd_range(1,25))=1
        'crew(slot).disease=rnd_range(1,17)
        if a=1 then 'captain
            crew(slot).hpmax=6
            crew(slot).hp=6
            crew(slot).icon="C"
            crew(slot).typ=1
        endif
        if a=2 then 'Pilot
            crew(slot).hpmax=player.pilot+1
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="P"
            crew(slot).typ=2
            crew(slot).paymod=player.pilot*player.pilot
        endif
        if a=3 then 'Gunner
            crew(slot).hpmax=player.gunner+1
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="G"
            crew(slot).typ=3
            crew(slot).paymod=player.gunner*player.gunner
        endif
        if a=4 then 'SO
            crew(slot).hpmax=player.science+1
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="S"
            crew(slot).typ=4
            crew(slot).paymod=player.science^2
        endif
        
        if a=5 then 'doctor
            crew(slot).hpmax=player.doctor+1
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="D"
            crew(slot).typ=5
            crew(slot).paymod=player.doctor^2
        endif
        if a=6 then 'green
            crew(slot).hpmax=2
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="@"
            crew(slot).typ=6
            crew(slot).paymod=1
            'crew(slot).disease=rnd_range(1,16)
        endif    
        if a=7 then 'vet
            crew(slot).hpmax=3
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="@"
            crew(slot).typ=7
            crew(slot).paymod=1
        endif
        if a=8 then 'elite
            crew(slot).hpmax=4
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="@"
            crew(slot).typ=8
            crew(slot).paymod=1
        endif
        if a=9 then 'insect warrior
            crew(slot).hpmax=5
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="I"
            crew(slot).typ=9
            crew(slot).paymod=1
            crew(slot).n=ucase(chr(rnd_range(97,122)))
            crew(slot).xp=-1
            for c=0 to rnd_range(1,6)+3
                crew(slot).n=crew(slot).n &chr(rnd_range(97,122))
            next
            crew(slot).morale=25000
        endif
        if a=10 then 'cephalopod
            crew(slot).hpmax=6
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="Q"
            crew(slot).typ=10
            crew(slot).paymod=0
            crew(slot).xp=-1
            crew(slot).n=alienname(2)
            crew(slot).morale=25000
        endif
        if a=11 then
            crew(slot).equips=1
            crew(slot).hpmax=2
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="d"
            crew(slot).typ=11
            crew(slot).paymod=0
            crew(slot).n="Neodog"
            crew(slot).xp=-1
            crew(slot).morale=25000
        endif
        if a=12 then
            crew(slot).equips=0
            crew(slot).hpmax=3
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="a"
            crew(slot).typ=12
            crew(slot).paymod=0
            crew(slot).n="Neoape"
            crew(slot).xp=-1
            crew(slot).morale=25000
        endif
        if a=13 then
            crew(slot).equips=1
            crew(slot).hpmax=6
            crew(slot).hp=crew(slot).hpmax
            crew(slot).icon="R"
            crew(slot).typ=13
            crew(slot).paymod=0
            crew(slot).n="Robot"
            crew(slot).xp=-1
            crew(slot).morale=25000
        endif
        if a=14 then 'SO
            player.science=3
            crew(4).hpmax=player.science+1
            crew(4).hp=crew(4).hpmax
            crew(4).icon="T"
            crew(4).typ=4
            crew(4).paymod=0
            crew(4).n=alienname(1)
            crew(4).xp=0
            crew(4).disease=0
        endif
        if a=15 then
            player.doctor=6
            crew(5).typ=5
            crew(5).icon="D"
            crew(5).paymod=1
            crew(5).hpmax=7
            crew(5).hp=7
            crew(5).n="Ted Rofes"
            crew(5).xp=0
        endif
        if slot>1 and rnd_range(1,100)<=33 then n(200,1)=gaintalent(slot)
        if slot=1 and rnd_range(1,100)<=50 then n(200,1)=gaintalent(slot)
    endif     
    return 0
end function    

function cureawayteam(where as short) as short
    dim as short bonus,pack,cured,sick,a
    dim as string text
    if where=0 then 'On planet=0 On Ship=1
        if _chosebest=0 then
            pack=findbest(19,-1)
        else
            pack=getitem()
            if item(pack).ty<>19 then
                dprint "You can't use that as a disease treatment kit.",14
                pack=-1
            endif
        endif
        if pack>0 then
            dprint "Using "&item(pack).desig &".",10
            bonus=item(pack).v1
            destroyitem(pack)
        else
            bonus=-3
        endif
    else
        bonus=findbest(21,-1)+3
    endif
    
    for a=0 to 128
        if crew(a).hpmax>0 and crew(a).hp>0 and (crew(a).onship=where or where=1) then
            if crew(a).disease>0 and rnd_range(1,6)+rnd_range(1,6)+bonus+player.doctor+addtalent(5,17,1)>5+crew(a).disease/2 then
                crew(a).disease=0
                crew(a).onship=0
                cured+=1
            endif
            if crew(a).disease>0 then sick+=1
        endif
    next
    if cured>1 then dprint cured &" members of your crew where cured.",10
    if cured=1 then dprint cured &" member of your crew was cured.",10
    if cured=0 and sick>0 then dprint "No members of your crew where cured.",14
    if sick>0 then dprint sick &" are still sick.",14
    if cured>0 then gainxp(5)
    return 0
end function


function healawayteam(byref a as _monster,heal as short) as short
    dim as short b,c,ex,fac,h
    static reg as single
    static doc as single
    for b=1 to a.hpmax
        if crew(b).hp>0 and crew(b).hp<crew(b).hpmax then ex=ex+1
        diseaserun(b)
    next
    fac=findbest(24,-1)
    
    if fac>0 then
        if item(fac).v1>0 then reg=reg+0.1
    endif
    if player.doctor>0 and crew(5).onship=0 then
       doc=doc+player.doctor/25+addtalent(5,17,.1)
    endif
    if heal>0 then heal=heal+player.doctor+addtalent(5,19,3)
    if reg>=1 then 
        heal=heal+reg
        reg=0
        h=1
    endif
    if doc>=1 then
        if rnd_range(1,6)+rnd_range(1,6)+player.doctor>10 then
            heal=heal+doc
            h=1
        endif
        doc=0
    endif
    do
    ex=0
        for b=1 to a.hpmax
            if heal>0 and crew(b).hp<crew(b).hpmax and crew(b).hp>0 then
                heal=heal-1
                if h=1 then h=2
                crew(b).hp=crew(b).hp+1
                ex=ex+1
            endif
        next
    loop until heal=0 or ex=0
    if player.doctor>0 and crew(5).onship=0 and h=2 then
        dprint "The doctor fixes some cuts and bruises"
        gainxp(5)
    endif
    if fac>0 and h=2 then 
        dprint "the nanobots heal your wounded"
        item(fac).v1=item(fac).v1-1
    endif
    hpdisplay(a)
    return heal
end function

function infect(a as short,dis as short) as short
    dim as short roll
    roll=rnd_range(1,6)+rnd_range(1,6)+player.doctor
    if roll<maximum(3,dis) and crew(a).hp>0 and crew(a).hpmax>0 then
        crew(a).disease=dis
        crew(a).duration=disease(dis).duration
        if dis>player.disease then player.disease=dis
        dprint "A crew member was infected with "&disease(dis).desig &"!",12
    endif
    return 0
end function

function diseaserun(onship as short) as short
    dim as short a,dam,total,affected,dis,dead,distotal
    dim text as string
    for a=2 to 128
        if crew(a).hpmax>0 and crew(a).hp>0 and crew(a).disease>0 then
            if crew(a).duration>0 then 
                if crew(a).duration=disease(crew(a).disease).duration then dprint "A crewmember gets sick.",14
                crew(a).duration-=1
                if crew(a).duration=0 then crew(a).disease=0
                if crew(a).duration>0 then
                    dam=rnd_range(0,abs(disease(crew(a).disease).dam))
                    if dam>0 then
                        crew(a).hp=crew(a).hp-dam
                        if crew(a).hp<=0 then 
                            crew(a).hp=0
                            crew(a).disease=0
                            dead+=1
                        endif
                        total=total+dam
                        affected+=1
                    endif
                endif
                if crew(a).duration=0 then
                    if rnd_range(1,100)<disease(crew(a).disease).fatality then
                        if crew(a).onship=onship then dprint "A crewmember dies of disease.",12
                        crew(a)=crew(0)
                        crew(a).disease=0
                    else
                        if crew(a).onship=onship then dprint " A crewmember recovers.",10
                        crew(a).disease=0
                    endif
                endif
            endif
        endif
        if a=2 and crew(a).hp<=0 and player.pilot>0 then 
            player.pilot=captainskill
            dead-=1
            dprint " Your pilot dies of disease!",12
        endif
        if a=3 and crew(a).hp<=0 and player.gunner>0 then 
            player.gunner=captainskill
            dead-=1
            dprint " Your gunner dies of disease!",12
        endif
        if a=4 and crew(a).hp<=0 and player.science>0 then 
            player.science=captainskill
            dead-=1
            dprint " Your science officer dies of disease!",12
        endif
        if a=5 and crew(a).hp<=0 and player.doctor>0 then 
            player.doctor=captainskill
            dprint " Your doctor dies of disease!",12
        endif
        if crew(a).disease>dis then dis=crew(a).disease
    next
    player.disease=dis
    if total=1 then dprint " A crewmember suffer "& total &" damage from disease.",14
    if total>1 then dprint affected &" crewmembers suffer "& total &" damage from disease.",14
    if dead=1 then dprint " A crewmember dies from disease.",12
    if dead>1 then dprint dead &" crewmembers die from disease.",12
    return 0
end function

function damawayteam(byref a as _monster,dam as short, ap as short=0,disease as short=0) as string
    dim text as string
    dim as short ex,b,t,last,armeff,reequip,roll
    dim target(128) as short
    dim stored(128) as short
    dim injured(13) as short
    dim killed(13) as short
    dim desc(13) as string
    desc(1)="Captain"
    desc(2)="Pilot"
    desc(3)="Gunner"
    desc(4)="Science officer"
    desc(5)="Ships doctor"
    desc(6)="Sec. member"
    desc(7)="Sec. member"
    desc(8)="Sec. member"
    desc(9)="Insect warrior"
    desc(10)="Cephalopod"
    desc(11)="Neodog"
    desc(12)="Neoape"
    desc(13)="Robot"
    'ap=1 Ignores Armor
    'ap=2 All on one, carries over
    'ap=3 All on one, no carrying over
    'ap=4 Ignores Armor, Robots immune
    if abs(player.tactic)=2 then dam=dam-player.tactic
    if dam<0 then dam=1
    for b=1 to 128
        if crew(b).hpmax>0 and crew(b).hp>0 and crew(b).onship=0 then
            last+=1
            target(last)=b
            stored(last)=crew(b).hp
        endif
    next
    if dam>a.armor/(2*last) then
        dam=dam-a.armor/(2*last)
        armeff=int(a.armor/(2*last))
    else
        armeff=dam-1
        dam=1
    endif
    if last>128 then last=128
    do
        t=rnd_range(1,last)
        if crew(target(t)).hp>0 then
            if ap=2 then
                dam=dam-crew(target(t)).hp
                crew(target(t)).hp=dam
            endif
            if ap=3 then
                crew(target(t)).hp=crew(target(t)).hp-dam
                dam=0
            endif
            if ap=0 or ap=1 or ap=4 then
                roll=rnd_range(1,20)
                if roll>2+a.secarmo(target(t))+crew(target(t)).augment(5)+player.tactic+addtalent(3,10,1)+addtalent(t,20,1) or ap=4 or ap=1 then
                    if not(crew(target(t)).typ=13 and ap=4) then crew(target(t)).hp=crew(target(t)).hp-1
                    dam=dam-1
                else
                    armeff+=1
                endif
            endif
        endif
        ex=1
        for b=1 to last
            if crew(target(b)).hp>0 then ex=0
        next 
    loop until dam<=0 or ex=1
    for b=1 to last
        if stored(b)>crew(target(b)).hp then
            if crew(target(b)).hp<=0 then
                killed(crew(target(b)).typ)+=1
                reequip=1
            else
                injured(crew(target(b)).typ)+=1
            endif
        endif
    next
    
    for b=1 to 13
        if injured(b)>0 then
            if injured(b)>1 then
                text=text &injured(b) &" "&desc(b)&"s injured. "
            else
                text=text &desc(b)&" injured. "
            endif
        endif
    next
    for b=1 to 13
        player.deadredshirts=player.deadredshirts+killed(b)
        if killed(b)>0 then
            if killed(b)>1 then
                text=text &killed(b) &" "&desc(b)&"s killed. "
            else
                text=text &desc(b)&" killed. "
            endif
            changemoral(-3*killed(b),0)
        endif
    next
    if armeff>0 then text=text &armeff &" prevented by armor"
    hpdisplay(a)
    if killed(2)>0 then player.pilot=captainskill
    if killed(3)>0 then player.gunner=captainskill
    if killed(4)>0 then player.science=captainskill
    if killed(5)>0 then player.doctor=captainskill
    if reequip=1 then equip_awayteam(player,a,player.map)
    return trim(text)
end function

function hpdisplay(a as _monster) as short
    dim as short hp,b,c,x,y
    hp=0
    a.hpmax=0
    a.hp=0
    for b=1 to 128
        if crew(b).hpmax>0 and crew(b).onship=0 then a.hpmax+=1
        if crew(b).hp>0 and crew(b).onship=0  then a.hp+=1
        if crew(b).hp>0 and crew(b).onship=0 then hp=hp+1
    next
    
    color 15,0
    locate 1,63
    print "Status ";
    color 11,0
    print "(";
    print using "##:";a.hpmax;
    if a.hp/a.hpmax<.7 then color 14,0
    if a.hp/a.hpmax<.4 then color 12,0
    print using "##";a.hp;
    color 11,0
    print ")"
   
    for y=2 to 6
        locate y,63
        for x=1 to 15
            c=c+1
            if crew(c).hpmax>0 and crew(c).onship=0 then
                if crew(c).hp>0  then
                    color 14,0
                    if crew(c).hp=crew(c).hpmax then color 10,0
                    print crew(c).icon;       
                else
                    color 12,0
                    print "X";
                endif
            endif
        next
    next
    return 0
end function

function gainxp(slot as short) as short
    if crew(slot).hp>0 and crew(slot).xp>=0 then crew(slot).xp+=1
    return 0
end function
    
function gaintalent(slot as short) as string
    dim text as string
    dim roll as short
    ' roll for talent
    roll=rnd_range(1,25)
    ' check if can have it
    if roll<=6 and slot=1 then
        crew(slot).talents(roll)+=1
        text=text &crew(slot).n &" is now "& talent_desig(roll) &"("&crew(slot).talents(roll)&"). "
        if roll=1 then
            captainskill=captainskill+1
        endif
        'haggler
        'confident
        'charming
        'gambler
        'merchant
    endif
    
    if roll>=7 and roll<=9 and slot=2 then
        crew(slot).talents(roll)+=1
        text=text &crew(slot).n &" is now "& talent_desig(roll) &"("&crew(slot).talents(roll)&"). "
    endif
    
    if roll>=10 and roll<=13 and slot=3 then
        crew(slot).talents(roll)+=1
        text=text &crew(slot).n &" is now "& talent_desig(roll) &"("&crew(slot).talents(roll)&"). "
    endif
    
    if roll>=14 and roll<=16 and slot=4 then
        crew(slot).talents(roll)+=1
        text=text &crew(slot).n &" is now "& talent_desig(roll) &"("&crew(slot).talents(roll)&"). "
    endif
    
    if roll>=17 and roll<=19 and slot=5 then
        crew(slot).talents(roll)+=1
        text=text &crew(slot).n &" is now "& talent_desig(roll) &"("&crew(slot).talents(roll)&"). "
    endif
    
    if roll>19 then
        crew(slot).talents(roll)+=1
        text=text &crew(slot).n &" is now "& talent_desig(roll) &"("&crew(slot).talents(roll)&"). "
    endif
    if roll=20 then 
        crew(slot).hpmax+=1
        crew(slot).hp+=1
    endif
    return text
end function


function levelup(p as _ship) as _ship
    dim a as short
    dim vet as short
    dim elite as short
    dim text as string
    dim roll as short
    dim secret as short
    dim target as short
    dim _del as _crewmember
    
    dim lev(128) as byte
    for a=1 to 128
        if crew(a).hp>0  then
            roll=rnd_range(1,crew(a).xp)
            if roll>5+crew(a).hp^2 and crew(a).xp>0 then
                lev(a)+=1
            'else
             '   dprint "Rolled "&roll &", needed "&5+crew(a).hp^2,14,14
            endif
            if a>1 then
                if rnd_range(1,100)>10+crew(a).morale+addtalent(1,4,10) and crew(a).hp>0 then
                    if a=2 then 
                        text =text &" Pilot "&crew(a).n &" retired."
                        player.pilot=captainskill
                    endif
                    if a=3 then 
                        text =text &" Gunner "&crew(a).n &" retired."
                        player.gunner=captainskill
                    endif
                    if a=4 then 
                        text =text &" Science Officer "&crew(a).n &" retired."
                        player.science=captainskill
                    endif
                    if a=5 then 
                        text =text &" Doctor "&crew(a).n &" retired."
                        player.doctor=captainskill
                    endif
                    if a>5 then secret+=1
                    crew(a)=_del
                    lev(a)=0
                endif
            endif
        endif
    next
    if secret>1 then text=text &" " & secret &" of your security personal retired."
    if text<>"" then dprint text,10
    text=""
    if lev(1)=1 then
        if rnd_range(1,100)<crew(1).xp*4 then
            'add talent
            text=text &gaintalent(1)
            crew(1).xp=0
        endif
    endif
    if p.pilot>0 and p.pilot<=5 and lev(2)=1 then
        p.pilot+=1
        crew(2).hpmax+=1
        text=text &" Your pilot is now skill "&p.pilot &"."
        if rnd_range(1,100)<crew(2).xp*3 then text=text &gaintalent(2)
        crew(2).xp=0
    endif
    if p.gunner>0 and p.gunner<=5 and lev(3)=1 then
        p.gunner+=1
        crew(3).hpmax+=1
        text=text &" Your gunner is now skill "&p.gunner &"."
        if rnd_range(1,100)<crew(3).xp*3 then text=text &gaintalent(3)
        crew(3).xp=0
    endif
    if p.science>0 and p.science<=5 and lev(4)=1 then
        p.science+=1
        crew(4).hpmax+=1
        text=text &" Your science officer is now skill "&p.science &"."
        if rnd_range(1,100)<crew(4).xp*3 then text=text &gaintalent(4)
        crew(4).xp=0
    endif
    if p.doctor>0 and p.doctor<=5 and lev(5)=1 then
        p.doctor+=1
        crew(5).hpmax+=1
        text=text &" Your doctor is now skill "&p.doctor &"."
        if rnd_range(1,100)<crew(5).xp*3 then text=text &gaintalent(5)
        crew(5).xp=0
    endif
    for a=6 to 128
        if crew(a).hp>0 and lev(a)=1 and crew(a).typ>=6 and crew(a).typ<=7 then
            crew(a).hpmax+=1
            crew(a).typ+=1
            if rnd_range(1,100)<crew(a).xp*3 then text=text &gaintalent(a)
            crew(a).xp=0
            if crew(a).typ=7 then 
                vet+=1
            endif
            if crew(a).typ=8 then
                elite+=1
            endif
        endif
    next
    if vet=1 then
        for a=6 to 128
            if lev(a)=1 and crew(a).typ=7 then text=text &crew(a).n &" is now a veteran."
        next
    endif
    if elite=1 then
        for a=6 to 128
            if lev(a)=1 and crew(a).typ=8 then text=text &crew(a).n &" is now elite."
        next
    endif
    if vet>1 then text=text &" "&vet &" of your security are now veterans."
    if elite>1 then text=text &" "&elite &" of your security are now veterans."
    if text<>"" then dprint text,10
    displayship()
    return p
end function

function dplanet(p as _planet,orbit as short,scanned as short) as short
    dim a as short
    dim text as string
    locate 22,1,0
    color 11,1
    for a=1 to 61
        locate 22,a,0
        print CHR(196)
    next
    for a=1 to 25
        locate a,62,0,0
        print CHR(179);
    next
    locate 22,62,0
    print chr(180)    
    color 15,0
    locate 1,63
    print "Scanning Results:"
    color 11,0
    locate 2,63 
    print "Planet in orbit " & orbit
    locate 3,63
    print scanned &" km2 scanned"
    locate 5,63 
    print p.water &"% Liq. Surface"
    text=atmdes(p.atmos) &" atmosphere"
    locate 7,63
    if len(text)<17 then 
        print text
    else
        textbox(text,63,7,16,11,0)    
    endif
    locate 12,63
    print "Gravity:";
    print using "####.#";p.grav;
    print " g"
    locate 14,63
    print "Avg. Temperature"
    locate 16,63
    print using "####.#";p.temp;
    print " "&chr(248)&"c"
    locate 18,63
    print "Rot.:";
    if p.rot>0 then
        print using "####.#";p.rot*24;
        print " h"
    else
        print " Nil"
    endif
    locate 20,63
    print "Lifeforms:"
    locate 21,64
    print p.life*10 &" % probability"
    return 0
end function

function blink(byval p as _cords) as short
    
    locate p.y+1,p.x+1
    if p.x>80 then p.x=80
    if p.y>25 then p.y=25
    if timer>zeit then
        color 11,11
        print " ";
        if timer>zeit+0.5 then zeit=timer+0.5
    elseif timer<=zeit then
        color 11,3
        print " ";
    endif
    return 0
end function

function cursor(byref target as _cords,map as short,curs as short=0) as string
    dim key as string
    dim cursorp as _cords
    cursorp=target
    if curs=1 then
        cursorp.x=pos-1
        cursorp.y=csrlin-1
    endif
    do
        blink(cursorp)
        key=keyin("",1,1)
    loop until key<>""
    'dprint ""&planetmap(target.x,target.y,map)
    locate target.y+1,target.x+1
    if map>0 then
        if planetmap(target.x,target.y,map)<0 then
            color 0,0
            print " "
        else
            if target.x>=0 and target.y>=0 and target.x<=60 and target.y<=20 then dtile(target.x,target.y,tiles(planetmap(target.x,target.y,map)))
        endif
    else
        color 0,0
        print " "
    endif
    if curs=0 then target=movepoint(target,getdirection(key))
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
    if rnd_range(1,6)+rnd_range(1,6)+player.science>9 then enemy.stuff(10)=1
    if rnd_range(1,6)+rnd_range(1,6)+player.science>10 then enemy.stuff(11)=1
    if rnd_range(1,6)+rnd_range(1,6)+player.science>11 then enemy.stuff(12)=1
    enemy.stuff(9)=enemy.stuff(10)+enemy.stuff(11)+enemy.stuff(12)
    endif
    if enemy.stuff(10)=1 then text=text &"(" &enemy.hpmax &"/" &enemy.hp &")"
    if enemy.stuff(11)=1 then text=text &" W:" &enemy.weapon
    if enemy.stuff(12)=1 then text=text &" A:" &enemy.armor
    if enemy.hp>0 and enemy.aggr=0 then text=text &". it is attacking!"
    return text
end function

sub show_stars(bg as short=0,byref walking as short)
    dim as short a,b,x,y,navcom,mask
    dim as _cords p,p1,p2
    dim range as integer
    dim as single dx,dy,l,x1,y1,vis
    dim m as _monster
    dim vismask(sm_x,sm_y) as byte
    if bg<2 then
        player.osx=player.c.x-30
        player.osy=player.c.y-10
        if player.osx<=0 then player.osx=0
        if player.osy<=0 then player.osy=0
        if player.osx>=sm_x-60 then player.osx=sm_x-60
        if player.osy>=sm_y-20 then player.osy=sm_y-20
    endif
    m.sight=player.sensors+5.5
    m.c=player.c
    makevismask(vismask(),m,-1)
    navcom=findbest(52,-1)
    for x=player.c.x-1 to player.c.x+1
        for y=player.c.y-1 to player.c.y+1
            if x>=0 and y>=0 and x<=sm_x and y<=sm_y then vismask(x,y)=1
        next
    next
    
    if bg>0 then
        for x=0 to 60
            for y=0 to 20
                locate y+1,x+1,0
                color 1,0
                if spacemap(x+player.osx,y+player.osy)=1 and navcom>0 then 
                    if _tiles=0 then
                        put (x*8+1,y*16+1),gtiles(11),pset
                    else
                        print ".";
                    endif
                endif
                if spacemap(x+player.osx,y+player.osy)>=2 and  spacemap(x+player.osx,y+player.osy)<=5 then 
                    if _tiles=0 then
                        put (x*8+1,y*16+1),gtiles(9),pset
                    else                        
                        color rnd_range(48,59),1
                        if spacemap(x+player.osx,y+player.osy)=2 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(48,59),1
                        if spacemap(x+player.osx,y+player.osy)=3 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(96,107),1
                        if spacemap(x+player.osx,y+player.osy)=4 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(144,155),1
                        if spacemap(x+player.osx,y+player.osy)=5 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(192,203),1
                        print chr(176); 
                    endif
                endif
                if abs(spacemap(x+player.osx,y+player.osy))=6 or abs(spacemap(x+player.osx,y+player.osy))=7 or abs(spacemap(x+player.osx,y+player.osy))=8 then
                    if abs(spacemap(x+player.osx,y+player.osy))=6 then color 9,0
                    if abs(spacemap(x+player.osx,y+player.osy))=7 then color 113,0
                    if abs(spacemap(x+player.osx,y+player.osy))=8 then color 53,0
                    if spacemap(x+player.osx,y+player.osy)=6 or spacemap(x+player.osx,y+player.osy)=7 or spacemap(x+player.osx,y+player.osy)=8  then 
                        print ":";
                    else
                        if navcom>0 then print "."
                    endif
                endif
            next
        next
    endif
    color 1,0
    for x=player.c.x-10 to player.c.x+10
        for y=player.c.y-10 to player.c.y+10
            if x-player.osx>=0 and y-player.osy>=0 and x-player.osx<=60 and y-player.osy<=20 and x>=0 and y>=0 and x<=sm_x and y<=sm_y then
                p.x=x
                p.y=y
                if vismask(x,y)>0 and distance(p,player.c)<player.sensors+0.5 then 
                    if spacemap(x,y)=0 and navcom>0 then spacemap(x,y)=1
                    if spacemap(x,y)=-2 then spacemap(x,y)=2
                    if spacemap(x,y)=-3 then spacemap(x,y)=3
                    if spacemap(x,y)=-4 then spacemap(x,y)=4
                    if spacemap(x,y)=-5 then spacemap(x,y)=5
                endif
                locate y+1-player.osy,x+1-player.osx,0
                color 1,0
                if abs(spacemap(x,y))=1 and navcom>0 and vismask(x,y)>0 and distance(p,player.c)<player.sensors+0.5  then
                    if _tiles=1 then
                        print ".";
                    else
                        put ((x-player.osx)*8+1,(y-player.osy)*16+1),gtiles(11),pset
                    endif
                endif
                if abs(spacemap(x,y))>=2 and abs(spacemap(x,y))<=5 and vismask(x,y)>0  and distance(p,player.c)<player.sensors+0.5 then 
                    if _tiles=1 then
                        color rnd_range(48,59),1
                        if spacemap(x,y)=2 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(48,59),1
                        if spacemap(x,y)=3 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(96,107),1
                        if spacemap(x,y)=4 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(144,155),1
                        if spacemap(x,y)=5 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(192,203),1
                        print chr(176); 
                    else                        
                        put ((x-player.osx)*8+1,(y-player.osy)*16+1),gtiles(9),pset
                    endif
                endif
                if abs(spacemap(x,y))>=6 and abs(spacemap(x,y)<=8) and vismask(x,y)>0 and distance(p,player.c)<player.sensors+0.5 then
                    if spacemap(x,y)=6 or spacemap(x,y)=7 or spacemap(x,y)=8 or rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then 
                        if abs(spacemap(x,y))=6 then color 9,0
                        if abs(spacemap(x,y))=7 then color 113,0
                        if abs(spacemap(x,y))=8 then color 53,0
                        print ":";
                        if abs(spacemap(x,y))=6 then spacemap(x,y)=6
                        if abs(spacemap(x,y))=7 then spacemap(x,y)=7
                        if abs(spacemap(x,y))=8 then spacemap(x,y)=8
                    else
                        if navcom>0 then print "."
                    endif
                endif
            endif
        next
    next


    a=findbest(51,-1)
    if a>0 then
        for b=1 to lastfleet
            x=fleet(b).c.x
            y=fleet(b).c.y
            locate y+1-player.osy,x+1-player.osx,0
            if vismask(x,y)=1 and distance(player.c,fleet(b).c)<player.sensors then
                color 11,0 
                if item(a).v1=1 then
                    color 11,0 
                    print "s"
                else
                    if fleet(b).ty=1 or fleet(b).ty=3 then color 10,0
                    if fleet(b).ty=2 or fleet(b).ty=4 then color 12,0
                    print "s"
                endif
            else
                color 1,0
                if navcom>0 then 
                   if spacemap(x,y)=1 then print ".";
                else
                   if spacemap(x,y)>=2 and spacemap(x,y)<=5 then
                        color rnd_range(9,14),1
                        if spacemap(x,y)=2 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(48,59),1
                        if spacemap(x,y)=3 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(96,107),1
                        if spacemap(x,y)=4 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(144,155),1
                        if spacemap(x,y)=5 and rnd_range(1,6)+rnd_range(1,6)+player.pilot>8 then color rnd_range(192,203),1
                        print chr(176); 
                   else
                        print " ";
                   endif
                endif
            endif
        next
    endif
    for x=0 to lastdrifting
        if drifting(x).x<0 then drifting(x).x=0
        if drifting(x).y<0 then drifting(x).y=0
        if drifting(x).x>sm_x then drifting(x).x=sm_x
        if drifting(x).y>sm_y then drifting(x).y=sm_y
        p.x=drifting(x).x
        p.y=drifting(x).y
        
        if planets(drifting(x).m).flags(0)=0 then
            color 7,0
            if (a>0 and vismask(p.x,p.y)=1 and distance(player.c,p)<player.sensors) or drifting(x).p>0 then
                if p.x+1-player.osx>0 and p.x+1-player.osx<61 and p.y+1-player.osy>0 and p.y+1-player.osy<21 then 
                    locate p.y+1-player.osy,p.x+1-player.osx
                    print "s"
                    if drifting(x).p=0 and walking<>0 then walking=0
                    drifting(x).p=1
                endif
            endif
        endif
    next
    
    color rnd_range(69,71),rnd_range(227,229)
    if _showcomments=0 then
        for a=1 to lastcom
            if coms(a).c.x>player.osx and coms(a).c.x<player.osx+60 and coms(a).c.y>player.osy and coms(a).c.y<player.osy+20 then
                locate coms(a).c.y+1-player.osy,coms(a).c.x+1-player.osx
                for b=1 to coms(a).l
                    color rnd_range(69,71),rnd_range(227,229)
                    print mid(coms(a).t,b,1);
                next
            endif
        next
    endif
    
    for a=0 to laststar+wormhole
        if map(a).spec<>8 then
            vis=maximum(player.sensors+.5,(map(a).spec)-2)
        else
            vis=0
        endif
            
        if (vismask(map(a).c.x,map(a).c.y)=1 and distance(map(a).c,player.c)<=vis) or map(a).discovered>0 then 
            if map(a).discovered=0 and walking<>0 then walking=0
            displaystar(a)
        endif
    next
    
    for a=0 to 2
        if basis(a).discovered>0 then displaystation(a)
    next
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
    static scrn(80,25,2) as integer
    dim as short x,y,f,b
    dim as integer bg,fg,col
    dim as string fname
    dim row as wstring*80
    'a=0 screen in file drucken
    'a=1 screen in scrn speichern
    'a=2 screen aus scrn ausgeben
    if _tiles=0 then
        if a=0 then dprint "Screenshots in graphics mode not possible."
        if a=1 then get(0,0)-(600,300),scr
        if a=2 then put (0,0),scr,pset
    else        
        if a=0 or a=1 then
            for x=1 to 80
                for y=1 to 25
                    scrn(x,y,0)=screen(y,x)
                    col = Screen(y,x,1)
                    scrn(x,y,1) = col And &HFF
                    scrn(x,y,2) = (col Shr 8) And &HFF
                next
            next
        endif
        
        if a=0 then
            'find filename
            do
                b=b+1
                fname="scrn"& b &".txt"
            loop until not(fileexists(fname)) or b>255
            f=freefile
            open fname for output as #f
            for y=1 to 25
                row=""
                for x=1 to 80
                    
                        row=row &chr850(scrn(x,y,0))
                    
                next
                print #f,row
            next
            close #f
            dprint "screenshot saved as "&fname
        endif
        
        if a=2 then
            for y=1 to 25
                for x=1 to 80
                    fg=scrn(x,y,1)
                    bg=scrn(x,y,2)
                    locate y,x,0
                    color fg,bg
                    print chr(scrn(x,y,0));
                next
            next
        endif
    endif
    color 11,0
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


function logbook() as short
    cls
    dim lobk(30,20) as string 'lobk is description
    dim lobn(30,20) as short 'lobn is n to get map(n)
    dim lobc(30,20) as short 'lobc is bg color
    static as _cords curs,curs2
    dim as short x,y,a,b,p,m,lx,ly,dlx
    dim as string key, lobk1, lobk2
    x=0
    y=0
    for a=0 to laststar
        if trim(map(a).desig)<>"" then
            if map(a).spec<8 or map(a).discovered>1 then
                lobk(x,y)=trim(map(a).desig)
                lobn(x,y)=a
                y=y+1
                if y>20 then
                    y=0
                    x=x+1
                endif
            endif
        endif
    next
    lx=x
    b=0
    if y<>0 then ly=y+(lx*21) else ly=(lx*21)-1
    if y=0 then lx-=1
    for a=0 to ly       'tests all lobk() and order them by coordenates
        for b=0 to (ly-1)   'ly is not coord, it is counter for planet check
            'print "testing x and y of 1st system: " &lobk(int(b/21), ((b) mod 21)) &" b=" & b &" b mod21:" &(b mod 21) &" a=" &a
            'print "testing x and y of 2nd system: " &lobk(int((b+1)/21), ((b+1) mod 21)) &" b=" & b &" b mod21:" &(b mod 21) &" a=" &a
            'sleep
            lobk1=mid(lobk(int(b/21), (b mod 21)), 3)
            'this is first lobk(x,y)==> val(mid(lobk(int(y/20)+1,(y mod 20) + 1),4))
            do
                lobk1 = mid(lobk1, 2)
            loop until left(lobk1,1) = "(" or left(lobk1,1)=""
            lobk1 = mid(lobk1, 2)
            
            lobk2 = mid(lobk(int((b+1)/21),((b+1) mod 21)),3)
            do
                lobk2 = mid(lobk2, 2)
            loop until left(lobk2,1) = "(" or left(lobk2,1)=""
            lobk2 = mid(lobk2, 2)
            
            if val(lobk1) > val(lobk2) or lobk1="" then
                swap lobk(int(b/21), (b mod 21)), lobk(int((b+1)/21),((b+1) mod 21))
                swap lobn(int(b/21), (b mod 21)), lobn(int((b+1)/21),((b+1) mod 21))
            endif
            'if first x cord in string lobk is bigger then swap with next item of list
            if val(lobk1) = val(lobk2) then
                'if x cords are equal, test y cords
                do
                    lobk1 = mid(lobk1, 2)
                loop until left(lobk1,1) = ":" or left(lobk1,1)=""
                lobk1 = mid(lobk1, 2)
                'check for y cords in lobk1/2 strings
                
                do
                    lobk2 = mid(lobk2, 2)
                loop until left(lobk2,1) = ":" or left(lobk2,1)=""
                lobk2 = mid(lobk2,2)
                'check for y cords in lobk1/2 strings
                
                if val(lobk1) > val(lobk2) then 'swap to next if x of lobk2 is bigger
                    swap lobk(int(b/21), (b mod 21)), lobk(int((b+1)/21),((b+1) mod 21))
                    swap lobn(int(b/21), (b mod 21)), lobn(int((b+1)/21),((b+1) mod 21))
                endif
            endif
        next
    next
    
    for a=0 to ly       'tests all lobn for special planets, system comments and planets comments for coloring bg
        'print "test for special planets and change lobc (bg color): system " &map(lobn(int(a/21), (a mod 21))).desig 'debug
        b=0
        if map(lobn(int(a/21), (a mod 21))).comment<>"" then lobc(int(a/21), (a mod 21))=228
        for p=1 to 9 'find number of planet in system's orbits
            m=map(lobn(int(a/21), (a mod 21))).planets(p)
            if m>0 then
                if planets(m).comment<>"" then lobc(int(a/21), (a mod 21))=241
                b+=1
            endif
        next
        print b 'debug msg
        for p=1 to b
            for b=0 to lastspecial
                'print "test for special planets and change lobc (bg color): system " &map(lobn(int(a/21), (a mod 21))).desig &" system orbit " &p 'debug
                if map(lobn(int(a/21), (a mod 21))).planets(p)>0 then
                    if planetmap(0,0,map(lobn(int(a/21), (a mod 21))).planets(p))<>0 and map(lobn(int(a/21), (a mod 21))).planets(p)=specialplanet(b) then lobc(int(a/21), (a mod 21))=233
                endif
            next
        next
    next
    'sleep 2000 'debug
    
'    'to test columns wraping create many extra systems and color them with palette
'    ly+=256
'    lx=int(ly/21)
'    for b=ly-255 to ly
'        if lobk(int(b/21), (b mod 21))="" then
'            lobn(int(b/21), (b mod 21))=lobn(0,0)
'            lobk(int(b/21), (b mod 21))="  color "+str(b-(ly-255))
'            print str(b+255-ly)
'            lobc(int(b/21), (b mod 21))=b-(ly-255)
'        endif
'    next
'    'end of test
    
    dlx=0
    dprint "Press " &key_sc &" or enter to choose system. ESC to exit."
    do

        x=0
        y=0
        cls
        displayship(1)
        'dlx is the first column shown on screen
        if curs.x<dlx then dlx-=1
        if curs.x>(dlx+4) then dlx+=1
        if curs.x=0 then dlx=0
        if curs.x=lx and lx>4 then dlx=lx-4
        if lobk(curs.x+1,curs.y)="" and curs.x>dlx+4 then dlx=lx-4 'when go back from first to last column and the element does not contain text it goes to the column before that, this correct the screen
        if curs.x<dlx or curs.x>(dlx+4) then dlx=int(curs.x/21)+2
        
        for x=dlx to (dlx+4)
            for y=0 to 20
                locate y+1,((x-dlx)*12)+1
                if x=curs.x and y=curs.y then
                    color 15,3
                else
                    color 11, 0
                    if lobc(x,y)<>0 then color 11, lobc(x,y)
                endif
                if lobk(x,y)<>"" then
                    print lobk(x,y)
                else
                    print "  "
                endif
            next
        next
        if map(lobn(curs.x,curs.y)).discovered>1 then 
            displaysystem(map(lobn(curs.x,curs.y)),1) 
        else
            dprint "Only long range data"
        endif
        if map(lobn(curs.x,curs.y)).comment<>"" then dprint map(lobn(curs.x,curs.y)).comment
        
        'fill msg area with planets comments, if there are more then shown, then msg there are more.
        p=0
        b=0
        lobk1=""
        if map(lobn(curs.x,curs.y)).comment<>"" then b=1
        do 'print max of 2 planets comments
            p+=1
            m=map(lobn(curs.x,curs.y)).planets(p)
            if m>0 then
                if planets(m).comment<>"" then
                    if b<2 then dprint "Orbit " &p &": " &planets(m).comment &"." 'print when b=0 or b=1
                    if b=2 then lobk1=str(p) &": " &planets(m).comment &"." 'store third planet comments
                    b+=1
                endif
            endif
        loop until p=9 or b=4 'test for 4 planets with comments
        if b>1 and lobk1<>"" then
            if b=3 then dprint "Orbit " &lobk1 endif
            if b=4 then dprint "Orbit " &lobk1 &" Enter to see more comments."
        endif
        
        
        key=keyin("123456789 " &key_sc &key_esc &key_enter &key_comment)
        'make curs goes arround edges
        a=getdirection(key)
        if a=5 then key=key_enter endif
        if a=1 then
            curs.x=curs.x-1
            curs.y=curs.y+1
            'if diagonal don't wrap on up and down edges
            if curs.y=21 then curs.y=20 endif
        endif
        if a=2 then
            curs.x=curs.x
            curs.y=curs.y+1
        endif
        if a=3 then
            curs.x=curs.x+1
            curs.y=curs.y+1
            'if diagonal don't wrap on up and down edges
            if curs.y=21 then curs.y=20 endif
        endif
        if a=4 then
            curs.x=curs.x-1
            curs.y=curs.y
        endif
        if a=6 then
            curs.x=curs.x+1
            curs.y=curs.y
        endif
        if a=7 then
            curs.x=curs.x-1
            curs.y=curs.y-1
            'if diagonal don't wrap on up and down edges
            if curs.y=-1 then curs.y=0 endif
        endif
        if a=8 then
            curs.x=curs.x
            curs.y=curs.y-1
        endif
        if a=9 then
            curs.x=curs.x+1
            curs.y=curs.y-1
            'if diagonal don't wrap on up and down edges
            if curs.y=-1 then curs.y=0 endif
        endif
        if curs.x<0 or curs.x>lx or curs.y<0 or curs.y>20 then
            if curs.y<0 then
                curs.y=20
                curs.x-=1
            endif
            if curs.y>20 then
                curs.y=0
                curs.x+=1
            endif
        endif
        if curs.x<0 then curs.x=lx endif
        if curs.x>lx then curs.x=0 endif

        if lobk(curs.x,curs.y)="" and curs.y>0 then 
            if a=4 or a=1 or a=7 then curs.x-=1 endif
            if a=6 or a=9 or a=3 or a=8 then 'returning from curs=(0,0) then search for valid system
                'going to last column , same row not valid then go last valid row
                do
                    curs.y-=1
                loop until lobk(curs.x,curs.y)<>"" or curs.y=0
            endif
            if a=2 then curs.x=0: curs.y=0 endif
        endif

        if key=key_comment and lobn(curs.x,curs.y)<>0 then
            dprint "Enter comment on system: "
            locEOL
            map(lobn(curs.x,curs.y)).comment=gettext(pos+1,csrlin-1,60,map(lobn(curs.x,curs.y)).comment)
            if map(lobn(curs.x,curs.y)).comment<>"" then lobc(curs.x,curs.y)=228
        endif
        
        if map(lobn(curs.x,curs.y)).discovered>1 and (key=key_enter or key=key_sc) then
            'print planets comments
                for p=1 to 9
                    if map(lobn(curs.x, curs.y)).planets(p)>0 then
                        if planets(map(lobn(curs.x,curs.y)).planets(p)).comment<>"" then dprint "Orbit " &p &":" &planets(map(lobn(curs.x,curs.y)).planets(p)).comment
                    endif
                next
            do
                p=getplanet(lobn(curs.x,curs.y),1)
                if p=-1 then no_key=key_esc
                if p>0 then
                    m=map(lobn(curs.x,curs.y)).planets(p)
                    if m>0 then
                        if planetmap(0,0,m)=0 then
                            cls
                            displayship(1)
                            locate 10,16
                            color 15,0
                            print"[No map data for this planet]"
                            no_key=keyin
                        else
                            cls
                            do
                                if planets(m).comment<>"" then dprint planets(m).comment
                                dplanet(planets(m),p,planets(m).mapped)
                                displayplanetmap(m)
                                no_key=keyin(key_comment &key_report &key_esc &key_sc &key_la &key_enter &key_yes)
                                if no_key=key_comment then
                                    dprint "Enter comment on planet: "
                                    locEOL
                                    planets(m).comment=gettext(pos+1,csrlin-1,60,planets(m).comment)
                                    if planets(m).comment<>"" and map(lobn(curs.x,curs.y)).comment="" then lobc(curs.x,curs.y)=241
                                endif
                                if no_key=key_report then
                                    bioreport(m)
                                endif    
                            loop until no_key<>key_comment or no_key<>key_report
                        endif
                    endif
                endif              
            loop until no_key=key_esc
            key=""
        endif
    loop until key=key_esc or player.dead<>0
    return 0
end function


function manual() as short
    dim as integer f,offset,c,a,lastspace
    dim lines(512) as string
    dim col(512) as short
    dim as string key,text
    dim evkey as EVENT
    screenshot(1)
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
            color 11,0
            for a=1 to 24
                locate a,1
                color col(a+offset),0
                print lines(a+offset);
            next
            locate 25,15
            color 14,0
            print "Arrow down and up to browse, space or esc to exit";
            key=keyin("12346789 " &key_esc,,1)
            if keyplus(key) or key=key_north or key="8" then offset=offset-22
            if keyminus(key) or key=key_south or key="2" then offset=offset+22
            if offset<0 then offset=0
            if offset>488 then offset=488
        loop until key=key_esc or key=" "
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
    dim a as short
    screenshot(1)
    cls
    for a=1 to 25
        locate a,1 
        color dtextcol(a),0
        print displaytext(a);
    next
    do
        screenevent(@evkey)
    loop until evkey.type<>1
    sleep 100
    no_key=keyin(,,1)
    cls
    screenshot(2)
    return 0
end function

function keyin(byref allowed as string="" , byref walking as short=0,blocked as short=0)as string
    dim key as string
    static as byte recording
    static as byte seq
    static as string*3 comseq
    dim as short a,b,i,tog1,tog2,tog3,tog4,ctr,f,it
    if walking<>0 then sleep 10
    flip
    
    do 
     do        
      If (ScreenEvent(@evkey)) Then
          Select Case evkey.type
          Case EVENT_KEY_PRESS
             select case evkey.scancode
              case sc_down
                 key = key_south
              case sc_up
                 key = key_north
              case sc_left
                 key = key_west
              case sc_right
                 key = key_east
              case sc_home
                 key = key_nw
              case sc_pageup
                 key = key_ne
              case sc_end
                 key = key_sw
              case sc_pagedown
                 key = key_se
              case sc_escape
                 key=key_esc
              case sc_enter
                 key=key_enter
              case else
                 key = chr(evkey.ascii)
              end select
           end select
           if evkey.type=13 then key=key_quit
          end if
         sleep 1
        loop until key<>"" or walking<>0 or (allowed="" and player.dead<>0)
        
        
        if key<>"" then walking=0 
        if blocked=0 then
            if key=key_manual then 
                manual
            endif
            if key=key_screenshot then 
                screenshot(0)
            endif
            if key=key_messages then 
                messages
            endif
            if key=key_configuration then
                configuration
            endif
            if key=key_tactics then
                settactics
            endif
            if key=key_shipstatus then         
                screenshot(1)
                shipstatus()
                screenshot(2)
            endif
            if key=key_logbook then
                screenshot(1)
                logbook
                screenshot(2)
            endif

            if key=key_equipment then
                screenshot(1)
                a=getitem(999)
                if a>0 then dprint item(a).ldesc
                key=keyin()
                screenshot(2)
            endif

            if key=key_quests then
                screenshot(1)
                showquests
                screenshot(2)
            endif
        endif
        if key=key_autoinspect then
            select case _autoinspect
                case is =0
                    _autoinspect=1
                    dprint "Autoinspect Off"
                case is =1
                    _autoinspect=0
                    dprint "Autoinspect On"                
            end select
            key=""     
        endif
        if key=key_autopickup then
            select case _autopickup
                case is =0
                    _autopickup=1
                    dprint "Autopickup Off"
                case is =1
                    _autopickup=0
                    dprint "Autopickup On"                
            end select
            key=""     
        endif
        if key=key_showcoms then
            select case _showcomments
                case is =0
                    _showcomments=1
                    dprint "Show comments on map Off"
                case is =1
                    _showcomments=0
                    dprint "Show comments on map On"
            end select
        endif
        if key=key_quit then 
            if askyn("Do you really want to QUIT and DELETE save files? (y/n)") then player.dead=6
        endif
        
        if len(allowed)>0 and key<>key_esc and key<>key_enter and getdirection(key)=0 then
            if instr(allowed,key)=0 then key=""
        endif
        if recording=2 then walking=-1
    loop until key<>"" or walking <>0
    while inkey<>""
    wend
    return key
end function

function keyplus(key as string) as short
    dim r as short
    if key=key_up or key=key_lt or key="+" then r=-1
    return r
end function

function keyminus(key as string) as short
    dim r as short
    if key=key_dn or key=key_rt or key="-" then r=-1
    return r
end function

sub displaystar(a as short)
    dim bg as short
    dim n as short
    dim p as short
    dim as short x,y
    x=map(a).c.x-player.osx
    y=map(a).c.y-player.osy
    if x<0 or y<0 or x>60 or y>20 then return
    bg=0
    if spacemap(map(a).c.x,map(a).c.y)>=2 then bg=5
    if spacemap(map(a).c.x,map(a).c.y)=6 then bg=1
    for p=1 to 9
        if map(a).planets(p)>0 then
            for n=0 to lastspecial
                color 11,0
                locate 1,1
                if map(a).planets(p)=specialplanet(n) and planetmap(0,0,map(a).planets(p))<>0 then 
                    bg=233
                endif
                if show_specials<>0 and map(a).planets(p)=specialplanet(show_specials) then
                    locate map(a).c.y-player.osy+2,map(a).c.x-player.osx+2,0
                    color 11
                    print ""&n
                endif
            next
            if planets(map(a).planets(p)).colony<>0 then bg=246
        endif
    next
    if map(a).discovered=0 then 
        player.discovered(map(a).spec)=player.discovered(map(a).spec)+1
        map(a).desig=spectralshrt(map(a).spec)&player.discovered(map(a).spec)&"-"&int(disnbase(map(a).c))&"("&map(a).c.x &":"& map(a).c.y &")"
        map(a).discovered=1
    endif
    if _tiles=0 then
        put ((map(a).c.x-player.osx)*8+1,(map(a).c.y-player.osy)*16+1),gtiles(map(a).spec+1),trans
    else        
        color spectraltype(map(a).spec),bg
        locate map(a).c.y+1-player.osy,map(a).c.x+1-player.osx,0
        if map(a).spec<8 then print "*"
        if map(a).spec=8 and map(a).discovered=2 then     
            color 7,bg
            print "o"
        endif
            
        if map(a).spec=9 then 
            n=distance(map(a).c,map(map(a).planets(1)).c)/5
            if n<1 then n=1
            if n>6 then n=6
            color 179+n,bg
            print "o"
        endif
    endif
end sub

sub displaystation(a as short)
    dim as short x,y
    basis(a).discovered=1
    x=basis(a).c.x-player.osx
    y=basis(a).c.y-player.osy
    if x<0 or y<0 or x>60 or y>20 then return
    color 15,0
    if _tiles=1 then
        locate basis(a).c.y+1-player.osy,basis(a).c.x+1-player.osx,0
        print "S"
    else
        put ((basis(a).c.x-player.osx)*8+1,(basis(a).c.y-player.osy)*16+1),gtiles(10),pset
    endif
end sub

sub dtile(x as short,y as short, tiles as _tile,bg as short=0)
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
        put (x*8,y*16),gtiles(tiles.no+19),pset
    else
        if _showvis=0 and bg>0 and bgcol=0 then 
            bgcol=234
        endif
        color col,bgcol
        print chr(tiles.tile)
    endif
    color 11,0    
end sub

sub displaysystem(sys as _stars,forcebar as byte=0)
    dim as short a,b,bg,x,y
    if _onbar=0 or forcebar=1 then
        locate 22,28
        color 11,1
        print chr(180)
        locate 22,29
    else
        x=sys.c.x-12-player.osx
        y=sys.c.y+2-player.osy
        if x<1 then x=1
        if x+21>59 then x=39
        locate y,x
        color 11,1
        print "[";
    endif
    color spectraltype(sys.spec),0
    print "*"&space(2);
    sys.discovered=2 
                
    for b=1 to 9
        
        'print isgasgiant(sys.planets(b))&sys.planets(b);
        color 0,0
        print " ";
        if sys.planets(b)=0 then
            print " ";
        endif
        bg=0
        for a=0 to lastspecial
            if sys.planets(b)>0 then
                if sys.planets(b)=specialplanet(a) and planetmap(0,0,sys.planets(b))<>0 then bg=233
            endif
        next
        if sys.planets(b)>0 and isgasgiant(sys.planets(b))=0 and isasteroidfield(sys.planets(b))=0 then            
            if planets(sys.planets(b)).colony>0 then bg=246
            if planets(sys.planets(b)).mapstat=1 then  
                if planets(sys.planets(b)).atmos=1 then color 15,bg      
                if planets(sys.planets(b)).atmos>1 and planets(sys.planets(b)).atmos<7 then color 101,bg
                if planets(sys.planets(b)).atmos>6 and planets(sys.planets(b)).atmos<12 then color 210,bg
                if planets(sys.planets(b)).atmos>11 then color 10,bg
            endif
            if planets(sys.planets(b)).mapstat=2 then  
            
                if planets(sys.planets(b)).atmos=1 then color 8,bg      
                if planets(sys.planets(b)).atmos>1 and planets(sys.planets(b)).atmos<7 then color 9,bg
                if planets(sys.planets(b)).atmos>6 and planets(sys.planets(b)).atmos<12 then color 198,bg
                if planets(sys.planets(b)).atmos>11 then color 54,bg
            endif
            if planets(sys.planets(b)).mapstat=0 then color 7,bg
            print "o";
         endif
         
         if isgasgiant(sys.planets(b))<>0 then
            if b>6 then
                color 63,bg
                print "O";
            endif
            if b>1 and b<7 then
                color 162,bg
                print "O";
            endif
            if b=1 then
                color 144,bg
                print "O";
            endif
        endif
        
        if (isgasgiant(sys.planets(b))=0 and sys.planets(b)<0) or isasteroidfield(sys.planets(b))<>0 then
            color 7,bg
            print chr(176);
        endif
    next
        
    if _onbar=0 or forcebar=1 then
        color 11,1
        print chr(195)
    else
        color 11,1
        print "]"
    endif
    color 11,0
end sub

sub displayawayteam(awayteam as _monster, map as short, lastenemy as short, deadcounter as short, ship as _cords, loctime as short, walking as short)
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
        xoffset=22
        if awayteam.oxygen=awayteam.oxymax then wg=0
        if awayteam.jpfuel=awayteam.jpfuelmax and awayteam.move=2 then wj=0
        locate 22,1
        color 15,0
        print space(32)
        locate 22,1
        'print awayteam.lastaction
        if awayteam.stuff(8)=1 and player.landed.m=map and planets(map).depth=0 then
            color 15,0
            locate 22,3
            print "Pos:";
            print using "##:##";awayteam.c.x,awayteam.c.y
        else
            locate 22,1
            color 14,0
            'print "no satellite"
        endif
        locate 22,15
        color 15,0
        if loctime=3 then print "Night"
        if loctime=0 then print " Day "
        if loctime=1 then print "Dawn "
        if loctime=2 then print "Dusk "
        color 10,0
        locate 22,xoffset
        if awayteam.invis>0 then
            print "Camo"
            xoffset=xoffset+5
        endif
        locate 22,xoffset
        if addtalent(-1,24,0)>0 then 
            print "Fast"
            xoffset=xoffset+5
        endif
        color 11,1
        locate 22,xoffset
        print chr(195)
        
        for a=xoffset+1 to 61
            locate 22,a,0
            print CHR(196)
        next
        for a=1 to 25
            locate a,62,0,0
            print CHR(179);
        next
        locate 22,62,0
        print chr(180)
        color 15,0
        if player.landed.m=map then
            if planetmap(ship.x,ship.y,map)>0 or player.stuff(3)=2 then    
                if _tiles=0 then
                    put (ship.x*8,ship.y*16),gtiles(12),trans
                else
                    color _shipcolor,0
                    locate ship.y+1, ship.x+1
                    print "@"                
                endif
            endif
        endif        
        if _tiles=0 then
            put (awayteam.c.x*8,awayteam.c.y*16),gtiles(13),trans
        else
            locate awayteam.c.y+1,awayteam.c.x+1
            color _teamcolor,0
            print "@" 
        endif    
        hpdisplay(awayteam)
        color 11,0
        locate 7,63
        print "Visibility:" &awayteam.sight
        locate 8,63
        if awayteam.move=0 then print "Trp.: None"
        if awayteam.move=1 then print "Trp.: Hoverplt."
        if awayteam.move=2 then print "Trp.: Jetpacks"
        if awayteam.move=3 then print "Trp.: Teleport(T)"
        
        locate 9,63
        print "Armor :";
        print using "###";awayteam.armor
        locate 10,63
        print "Firearms :";
        print using "###.#";awayteam.guns_to
        locate 11,63
        print "Melee :";
        print using "###.#";awayteam.blades_to
        if player.stuff(3)=2 then
            locate 12,63
            print "Alien Scanner"
            locate 13,63
            print "     [press " &key_sc & "]"
            locate 14,63
            print lastenemy-deadcounter &" Lifeforms "
        endif
        locate 15,63
        print "Mapped    :"& cint(reward(0))
        locate 16,63
        print "Bio Data  :"& cint(reward(1))
        locate 17,63
        print "Resources :"& cint(reward(2))
        locate 19,63
        print space(17);
        locate 19,63
        if len(tmap(awayteam.c.x,awayteam.c.y).desc)<18 then
            print tmap(awayteam.c.x,awayteam.c.y).desc ';planetmap(awayteam.c.x,awayteam.c.y,map) 
        else 
            dprint tmap(awayteam.c.x,awayteam.c.y).desc '&planetmap(awayteam.c.x,awayteam.c.y,map)
        endif
        
        if awayteam.move=2 then
            locate 21,63
            print key_ju &" for emerg."
            locate 22,63
            print "Jetpackjump"
        endif
        if awayteam.move=3 then
            locate 21,63
            print key_te &" activates"
            locate 22,63
            print "Transporter"
        endif
        if awayteam.move=2 and awayteam.hp>0 then
            color 11,0
            locate 23,63
            print "Jetpackfuel:";
            color 10,0
            if awayteam.jpfuel<awayteam.jpfuelmax*.5 then color 14,0
            if awayteam.jpfuel<awayteam.jpfuelmax*.3 then color 12,0
            if awayteam.jpfuel<0 then awayteam.jpfuel=0
            print using "###";awayteam.jpfuel/awayteam.hp
            if awayteam.jpfuel<awayteam.jpfuelmax then
                if awayteam.jpfuel/awayteam.jpfuelmax<.5 and wj=0 then 
                    wj=1
                    for a=1 to wj
                        if _sound=0 or _sound=2 then    
                            sleep 350
                            FSOUND_PlaySound(FSOUND_FREE, sound(1))                    
                            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)
                        endif
                    next    
                    dprint ("Jetpack fuel low",14)
                endif
                if awayteam.jpfuel/awayteam.jpfuelmax<.3 and wj=1 then 
                    wj=2
                    for a=1 to wj
                        if _sound=0 or _sound=2 then    
                            sleep 350
                            FSOUND_PlaySound(FSOUND_FREE, sound(1))                    
                            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)
                        endif
                    next    
                    dprint ("Jetpack fuel very low",14)
                    walking=0
                endif
                
                if awayteam.jpfuel<5 and wj=2 then 
                    wj=3
                    for a=1 to wj
                        if _sound=0 or _sound=2 then    
                            sleep 350
                            FSOUND_PlaySound(FSOUND_FREE, sound(1))                    
                            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)
                        endif
                    next    
                    dprint ("Switching to jetpack fuel reserve",12)
                endif
            else
                wj=0
            endif
        endif
        color 11,0
        locate 24,63
        print "Oxygen:";
        color 10,0
        if awayteam.oxygen<50 then color 14,0
        if awayteam.oxygen<25 then color 12,0
        print using "####";awayteam.oxygen/awayteam.hp
        if int(awayteam.oxygen<awayteam.oxymax*.5) and wg=0 then 
            dprint ("Reporting oxygen tanks half empty",14)
            wg=1
            for a=1 to wg
                if _sound=0 or _sound=2 then    
                    FSOUND_PlaySound(FSOUND_FREE, sound(1))                
                endif
            next
            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)
        endif
        if int(awayteam.oxygen<awayteam.oxymax*.25) and wg=1 then 
            dprint ("Oxygen low.",14)
            walking=0
            wg=2
            for a=1 to wg
                if _sound=0 or _sound=2 then
                    FSOUND_PlaySound(FSOUND_FREE, sound(1))   
                    sleep 350
                endif
            next
            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)       
        endif
        if int(awayteam.oxygen<awayteam.oxymax*.125) and wg=2 then
            dprint ("Switching to oxygen reserve!",12)
            wg=3
            for a=1 to wg
                if _sound=0 or _sound=2 then 
                    FSOUND_PlaySound(FSOUND_FREE, sound(1)) 
                    sleep 350
                endif
            next
            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)    
        endif
        color 11,0
        locate 25,63
        print "Turn:" &player.turn;
end sub

sub shipstatus(heading as short=0)
    dim as short c1,c2,c3,c4,c5,c6,c7,c8,sick,offset,mjs
    dim as short a,b,c,lastinv,set,tlen
    dim as string text,key
    dim inv(127) as _items
    dim invn(127) as short
    dim cargo(11) as string
    dim cc(11) as short
    dim flagst(16) as string
    flagst(1)="Fuel System"
    flagst(2)="Disintegrator"
    flagst(3)="Scanner"
    flagst(4)=" Ion canon"
    flagst(5)="Bodyarmor"
    flagst(6)="Engine"
    flagst(7)="Sensors"
    flagst(8)=" Cryochamber"
    flagst(9)="Teleportation device"
    flagst(10)=""
    flagst(11)=""
    flagst(12)="Cloaking device"
    flagst(13)="Wormhole shield"
    flagst(16)="Wormhole navigation device"
    
    color 0,0
    cls
    if heading=0 then
        color 15,0
        locate 1,2
        print "Name: ";
        color 11,0
        print player.desig &"   ";
        color 15,0
        print "Type: ";
        color 11,0
        print player.h_desig
    endif
    locate 3,3
    color 15,0
    print "Hullpoints(max";
    color 11,0
    print player.h_maxhull+player.addhull;
    color 15,0
    print "):";
    color 11,0
    if player.hull<(player.h_maxhull+player.addhull)/2 then color 14,0
    if player.hull<2 then color 12,0
    print player.hull
    locate 4,3
    color 15,0
    print "Shieldgenerator(max";
    color 11,0
    print player.shieldmax;
    color 15,0
    print "):";
    color 11,0
    if player.shield<player.shieldmax/2 then color 14,0
    print player.shield
    locate 5,3
    color 15,0
    print "Engine:";
    color 11,0
    print player.engine;
    color 15,0
    
    for a=1 to 5
        if player.weapons(a).made=88 then mjs+=1
        if player.weapons(a).made=89 then mjs+=2
    next
    print "("&player.engine+2-player.h_maxhull\15+mjs &" MP) Sensors:";    
    color 11,0 
    print player.sensors
    'Weapons
    c=player.h_maxweaponslot
    locate 7,3
    color 15,0
    print "Weapons:"
    color 11,0
    for a=1 to c
        if player.weapons(a).dam>0 then
            locate 8+b,3
            color 15,0
            print player.weapons(a).desig 
            color 11,0
            locate 8+b+1,3
            print " R:"& player.weapons(a).range &"/" & player.weapons(a).range*2 &"/" & player.weapons(a).range*3 &" D:"&player.weapons(a).dam ;
            if player.weapons(a).ammomax>0 then print " A:"&player.weapons(a).ammomax &"/" &player.weapons(a).ammo &"  "
            b=b+2
        else
            locate 8+b,4
            color 15,0
            if player.weapons(a).desig="" then
            print "-Empty-"
        else
            print player.weapons(a).desig
            endif
            b=b+1
        endif
    next
    'Cargo
    b=b-1
    text=cargobay(0)
    text=mid(text,6) 'first "SELL" out
    a=0
    locate 17,3
    color 15,0
    print "Cargo:"
    color 11,0
    cargo(1)="Empty"
    cargo(2)="Food, bought at"
    cargo(3)="Basic goods, bought at"
    cargo(4)="Tech goods, bought at"
    cargo(5)="Luxury goods, bought at"
    cargo(6)="Weapons, bought at"
    cargo(7)="Narcotics, bought at"
    cargo(8)="Hightech, bought at"
    cargo(9)="Computers, bought at"
    cargo(10)="Mysterious box"
    cargo(11)="TT Contract Cargo"
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
            print cc(c)&" x "&cargo(c)
        endif
    next
    locate 3,31
    color 15,0 
    print "Crew Summary"
    locate 5,31
    print "Pilot          :";
    if player.pilot >0 then
        color 11,0
        print player.pilot
    else 
        color 12,0
        print " - "
    endif
    locate 6,31
    color 15,0
    print "Gunner         :";
    if player.gunner>0 then
        color 11,0
        print player.gunner
    else 
        color 12,0
        print " - "
    endif
    locate 7,31
    color 15,0
    print "Science officer:";
    if player.science>0 then
        color 11,0
        print player.science
    else 
        color 12,0
        print " - "
    endif
    locate 8,31
    color 15,0
    print "Ship doctor    :";
    if player.doctor>0 then
        color 11,0
        print player.doctor
    else 
        color 12,0
        print " - "
    endif
    locate 10,31
    color 15,0
    print "Total bunks  :";
    color 11,0
    print player.h_maxcrew+player.crewpod
    locate 11,31
    color 15,0
    print "Cryo chambers:";
    color 11,0
    print player.cryo
    
    for a=6 to 128
       if crew(a).typ=6 then c1=c1+1
       if crew(a).typ=7 then c2=c2+1
       if crew(a).typ=8 then c3=c3+1
       if crew(a).typ=9 then c4=c4+1
       if crew(a).typ=10 then c5=c5+1
       if crew(a).typ=11 then c6=c6+1
       if crew(a).typ=12 then c7=c7+1
       if crew(a).typ=13 then c8=c8+1
       if crew(a).disease>0 then sick+=1
    next
    locate 12,31
    color 15,0
    print "Security:";
    color 11,0
    player.security=c1+c2+c3+c4+c5
    print c1+c2+c3+c4+c5
    color 15,0
    locate 14,33
    print "Elite    :";
    color 11,0
    print c3
    color 15,0
    locate 15,33
    print "Veterans :";
    color 11,0
    print c2
    locate 16,33
    color 15,0
    print "Green    :";
    color 11,0
    print c1
    if c4>0 then
        locate csrlin,33
        color 15,0
        print "Insectw. :";
        color 11,0
        print c4
    endif
    if c5>0 then
        locate csrlin,33
        color 15,0
        print "Cephalop.:";
        color 11,0
        print c5
    endif
    if c6>0 then
        locate Csrlin,33
        color 15,0
        print "Neodogs  :";
        color 11,0
        print c6
    endif
    if c7>0 then
        locate csrlin,33
        color 15,0
        print "Neoapes  :";
        color 11,0
        print c7
    endif
    if c8>0 then
        locate csrlin,33
        color 15,0
        print "Robots   :";
        color 11,0
        print c8
    endif
    c=0
    if sick>0 then
        locate csrlin+2,33
        color 14,0
        print "Sick :"&sick
    endif
    color 15,0
    locate 1,55
    print "Alien Artifacts"
    for a=1 to 16
        if artflag(a)>0 then
            c=c+1
            locate 11+c,58
            print flagst(a)
        endif
    next
    if c=0 then
        locate 2,60
        print "none"
    endif
    c+=1
    locate 2+c,55
    color 15,0    
    if heading=0 then
    lastinv=getitemlist(inv(),invn())     
    print "Equipment(";lastinv;"):"
    color 11,0
    if heading=0 then  
        do
            for a=0 to 22-c                
                locate 3+c+a,50
                color 0,0
                print space(30);
                color 11,0
                locate 3+c+a,50
                
                if invn(a+offset)>1 then
                    print invn(a+offset)&" "&left(inv(a+offset).desigp,27);
                else
                    if invn(a+offset)=1 then print invn(a+offset)&" "&left(inv(a+offset).desig,27);
                endif
            next
            locate 25,79
            color 0,0
            print " ";
            if lastinv>22-c and offset<lastinv then                    
                locate 25,79
                color 14,0
                print chr(25);
            endif
            locate 12,79
            color 0,0
            print " ";
            if offset>0 then    
                locate 1+c,79
                color 14,0
                print chr(24);
            endif
            key=keyin(,,1)
            if keyminus(key) or key=key_north then offset=offset-1
            if keyplus(key) or key=key_south then offset=offset+1
            if offset<0 then offset=0
            if offset>33 then offset=33
            loop until key=key_esc or key=" "
        endif
    endif
end sub

sub displayship(show as byte=0)
    dim  as short a,b,mjs
    static wg as byte
    dim t as string
    dim as string p,g,s,d
    if player.fuel=player.fuelmax then wg=0
    locate 22,1
    color 15,0
    if findbest(52,-1)>0 then
        print "Pos:";
        locate 22,5
        print using "##:##";player.c.x,player.c.y    
    else
        locate 22,1
        color 14,0
        print "No Navcomp"
    endif
        
    color 224,0
    locate 22,11
    print chr(195)
    for a=12 to 61
        locate 22,a,0
        print CHR(196)
    next
    for a=1 to 25
        locate a,62,0,0
        print CHR(179);
    next
    locate 22,62,0
    print chr(180)
    color 15,0
    locate 1,63
    print player.h_sdesc &" "& player.desig 
    color 11,0
    locate 2,63
    print "HP:"&space(4) &" "&"SP:"&player.shield &" "
    if player.hull<(player.h_maxhull+player.addhull)/2 then color 14,0
    if player.hull<2 then color 12,0
    locate 2,66
    print player.hull
    color 11,0
    p=""&player.pilot
    g=""&player.gunner
    s=""&player.science
    d=""&player.doctor
    if player.pilot<0 then p="-"
    if player.gunner<0 then g="-"
    if player.science<0 then s="-"
    if player.doctor<0 then d="-"
    player.security=0
    for a=6 to 128
       if crew(a).hpmax>=1 then player.security+=1
    next
    
    locate 3,63
    print "Pi:" & p & "  Gu:" &g &"  Sc:" &s
    locate 4,63
    print "Dr:"&d &"  Security:"&player.security
    locate 5,63
    print "Sensors:"&player.sensors
    locate 6,63
    
    for a=1 to 5
        if player.weapons(a).made=88 then mjs+=1
        if player.weapons(a).made=89 then mjs+=2
    next
    print "Engine :"&player.engine &" ("&player.engine+2-player.h_maxhull\15+mjs &" MP)"
    locate 23,63
    print "Fuel(" &player.fuelmax+player.fuelpod &"):"
    color 11,0
    if player.fuel<player.fuelmax*0.5 then 
        if wg=0 then
            wg=1 
            dprint "Fuel low",14
            if _sound=0 or _sound=2 then 
                 FSOUND_PlaySound(FSOUND_FREE, sound(2))                                       
            endif    
            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)
        endif
        color 14,0
        
    endif
            
    if player.fuel<player.fuelmax*0.2 then
        if wg=1 then
            wg=2
            dprint "Fuel very low",12
            if _sound=0 or _sound=2 then 
                 FSOUND_PlaySound(FSOUND_FREE, sound(2))
            endif
            if _sound=2 then no_key=keyin(" "&key_enter &key_esc)
 
        endif
        color 12,0
    endif
    locate 23,74
    print using "###";player.fuel
    color 11,0
    locate 24,63
    if player.money<1000000 then
        print using "Credits:######";player.money
    else
        print "Credits:";player.money
    endif
    locate 25,63
    print using "Turns:######";player.turn; 
    color 15,0
    locate 7,63
    print "Weapons:"
    color 11,0
    player.tractor=0
    for a=1 to 5
        if player.weapons(a).desig<>"" then
            locate 8+b,63
            color 15,0
            print trim(player.weapons(a).desig);
            color 11,0
            print " D:"&player.weapons(a).dam
            locate 8+b+1,63
            print "R:"& player.weapons(a).range &"/"& player.weapons(a).range*2 &"/" & player.weapons(a).range*3 ;
            if player.weapons(a).ammomax>0 then print " A:"&player.weapons(a).ammomax &"/" &player.weapons(a).ammo &" ";
            if player.weapons(a).ROF<0 then 
                player.tractor=1
                if player.towed>0 and rnd_range(1,6)+rnd_range(1,6)+player.pilot<8+player.weapons(a).ROF then
                    dprint "Your tractor beam breaks down",14
                    player.tractor=0
                    player.towed=0
                    player.weapons(a)=makeweapon(0)
                endif
            endif
        else
            locate 8+b,63
            print spc(15)
            locate 8+b+1,63
            print spc(15)
        endif
        b=b+2
    next
    locate 21,63
    print "Cargo"
    for a=1 to 10
        locate 22,62+a
        if player.cargo(a).x=1 then 
            color 8,1
            print "E"
        else
            color 10,8
        endif
        if player.cargo(a).x=2 then print "F"
        if player.cargo(a).x=3 then print "B"
        if player.cargo(a).x=4 then print "T"
        if player.cargo(a).x=5 then print "L"
        if player.cargo(a).x=6 then print "W"
        if player.cargo(a).x=7 then print "N"
        if player.cargo(a).x=8 then print "H"
        if player.cargo(a).x=9 then print "C"
        if player.cargo(a).x=10 then print "?"
        if player.cargo(a).x=11 then print "t"
    next
    if show=1 then
        if _tiles=0 then
            put ((player.c.x-player.osx)*8,(player.c.y-player.osy)*16),gtiles(12),trans
        else
            color _shipcolor,0
            locate player.c.y+1-player.osy,player.c.x+1-player.osx
            print "@"
        endif
    endif
    color 11,0
    if player.tractor=0 then player.towed=0
end sub

sub displayplanetmap(a as short)
    dim x as short
    dim y as short
    dim b as short
    for x=60 to 0 step-1
        for y=0 to 20
            if planetmap(x,y,a)>0 then
                dtile(x,y,tiles(planetmap(x,y,a)))
            endif
        next
    next
    for b=0 to lastportal
        if portal(b).from.m=a and portal(b).discovered=1 then
            locate portal(b).from.y+1,portal(b).from.x+1,0
            color portal(b).col,0
            print chr(portal(b).tile)            
        endif
        if portal(b).oneway=0 and portal(b).dest.m=a and portal(b).discovered=1 then
            locate portal(b).dest.y+1,portal(b).dest.x+1,0
            color portal(b).col,0
            print chr(portal(b).tile)
        endif
    next
    for b=1 to lastitem
        if item(b).w.m=a and item(b).w.s=0 and item(b).w.p=0 and item(b).discovered=1 then
            if _tiles=0 then
                if item(a).ty<>15 then
                    put (item(a).w.x*8,item(a).w.y*16),gtiles(item(a).ty+200),trans
                else                                
                    put (item(a).w.x*8,item(a).w.y*16),gtiles(item(a).v2+250),trans
                endif
            else            
                locate item(b).w.y+1,item(b).w.x+1
                color item(b).col,item(b).bgcol
                print item(b).icon
            endif
        endif
    next
end sub

function gettext(x as short, y as short, ml as short, text as string) as string
    dim l as short
    dim as string key, text1
    dim p as _cords
    text1=text
    l=len(text)
    sleep 150
    if l>ml and text<>"" then
        text=left(text,ml)
        l=ml
    endif
    locate y+1,x+1
    do 
        key=""
        color 11,0
        locate csrlin,x+1
        if len(text)+x+1>80 then locate csrlin-1,x+1
        print text;
        color 11,0
        print " ";
        color 11,0
        color 0,0
        print " ";
        color 11,0
        locate csrlin, pos-1
        do
            sleep 50
            do
                sleep 1
                locate csrlin, pos-1
                if timer>zeit then
                    color 3,0
                    print chr(17);
                    if timer>zeit+0.5 then zeit=timer+0.5
                elseif timer<=zeit then
                    color 11,0
                    print chr(17);
                    endif
            loop until screenevent(@evkey)
            if evkey.type=EVENT_KEY_press then
                if evkey.ascii=asc(key_esc) then key=key_esc
                if evkey.ascii=8 then key=chr(8)
                if evkey.ascii=32 then key=chr(32)
                if evkey.ascii=asc(key_enter) then key=key_enter
                if evkey.ascii>31 and evkey.ascii<168 then key=chr(evkey.ascii)
            endif
        loop until key<>""  

        if key=chr(8) and l>=1 then
           l=l-1
           text=left(text,len(text)-1)
           if text=chr(8) then text=""
        endif
        if l<ml and key<>key_enter and key<>chr(8) and key<>key_esc then
            text=text &key
            l=l+1
        endif
        
    loop until key=key_enter or key=key_esc
    if key=key_esc or l<1 then
        color 0,0
        locate y+1,x+1
        print space(len(text));
        text=text1
    endif
    if l=0 then text=""
    if text=key_enter or text=key_esc or text=chr(8) then text=""
    while inkey<>""
    wend
    return text
end function    

function textbox(text as string,x as short,y as short,w as short, fg as short=11, bg as short=0) as short
    dim as short lastspace,tlen,a,p,wcount,lcount
    dim words(1023) as string
    dim addt(24) as string
    addt(24)=text
    'if len(text)<=w then addt(0)=text
    for p=0 to len(text)
        words(wcount)=words(wcount)&mid(text,p,1)
        if mid(text,p,1)=" " or mid(text,p,1)="|" then wcount=wcount+1
    next
    for p=0 to wcount
        if words(p)="|" then 
            lcount=lcount+1
            p=p+1
        endif
        if len(addt(lcount)&words(p))>w then lcount=lcount+1
        addt(lcount)=addt(lcount)&words(p)
    next
    for a=0 to lcount
        addt(a)=addt(a)&space(w-len(addt(a)))
        locate y+1+a,x
        color fg,bg
        print addt(a)
    next
    text=addt(24)
    return lcount
end function

function locEOL() as short
    'puts cursor at end of last displayline
    dim as short y,x,a
    y=25
    for a=25 to 23 step -1
        if displaytext(a+1)="" then y=a
    next
    x=len(displaytext(y))
    locate y,x,0
    return 0
end function

function dprint(t as string, col as short=11,delay as byte=1) as short

    dim as short a,b,c
    dim text as string
    dim wtext as string
    dim offset as short
    dim tlen as short
    dim addt(64) as string
    dim lastspace as short
    dim key as string
    static lastcalled as double
    static lastmessage as string
    static lastmessagecount as short
    if t<>"" then
        if lastmessage=t then
            a=23
            do 
                a+=1
            loop until displaytext(a)="" or a=26
            a=a-1
            lastmessagecount+=1
            displaytext(a)=t &"(x"&lastmessagecount &")"
            t=""
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
    'find offset
    offset=23
    for a=23 to 26
        if displaytext(a)<>"" then offset=offset+1
    next
    for a=0 to len(t)
        if mid(t,a,1)<>"|" then text=text & mid(t,a,1)
    next
    if text<>"" then
        while len(text)>60
            lastspace=60
            do 
                lastspace=lastspace-1
            loop until mid(text,lastspace,1)=" "        
            if tlen>8 then tlen=8
            addt(tlen)=left(text,lastspace) 'string less than 60 character ending in space
            text=mid(text,lastspace+1,(len(text)-lastspace+1)) 'string from space with lenght of rest
            tlen=tlen+1 'tlen is number of lines
        wend
        addt(tlen)=text 'last line
        if offset+tlen>63 then offset=63-tlen 'offset is last line that text will occupy
            
        for a=offset to offset+tlen
            displaytext(a)=addt(a-offset) 'make lines 63-tlen to 63 as text
            dtextcol(a)=col
        next
        if tlen<=3 then
            if offset+tlen>25 then
                for c=0 to tlen
                    for b=0 to 29
                        displaytext(b)=displaytext(b+1)
                        dtextcol(b)=dtextcol(b+1)
                    next
                    displaytext(30)=""
                next
            endif
        else
            if offset>23 then
                for c=0 to 1
                    for b=0 to 29
                        displaytext(b)=displaytext(b+1)
                        dtextcol(b)=dtextcol(b+1)
                    next
                    displaytext(30)=""
                next
            endif
            a=0
            do
                for b=23 to 25
                    if displaytext(b)<>"" then a+=1
                    locate b,1,0
                    color 0,0
                    print space(60);
                    locate b,1,0
                    color dtextcol(b),0
                    print displaytext(b);
                next
                if displaytext(26)<>"" then
                    if a=3 then
                        locate 25,62,0
                        color 14,0
                        print chr(25);
                        no_key=keyin
                        a=0
                    endif
                    for c=0 to 1
                        for b=0 to 29
                            displaytext(b)=displaytext(b+1)
                            dtextcol(b)=dtextcol(b+1)
                        next
                        displaytext(30)=""
                    next
                endif
            loop until displaytext(26)=""
        endif
    endif
    for b=23 to 25
        locate b,1,0
        color 0,0
        print space(60);
        locate b,1,0
        color dtextcol(b),0
        print displaytext(b);
    next
    locate 24,1
    color 11,0
    return 0
end function    


function askyn(q as string,col as short=11) as short
    dim a as short
    dim key as string*1
    dprint (q,col)
    while screenevent(@evkey)
    wend
    do
        key=keyin
        displaytext(25)=q &" " &key
        if key <>"" then 
            dprint ""
            if _anykeyno=0 and (key<>key_yes or key<>key_enter) then key=chr(18)
        endif
    loop until key=chr(18) or key="n" or key=" " or key=key_esc or key=key_enter or key=key_yes
    if key=key_yes or key=key_enter then a=-1
'    if int((len(displaytext(25))+3)/60)>0 then
'        displaytext(25)=""
'        dprint q &" " &key
'    endif
    return a
end function

function menu(te as string, he as string="", x as short=2, y as short=2, blocked as short=0) as short
    ' 0= headline 1=first entry
    dim as short blen
    dim as string text,help
    dim lines(25) as string
    dim helps(25) as string
    dim shrt(25) as string
    dim as string key,delhelp
    dim a as short
    dim b as short
    dim c as short
    static loca as short
    dim e as short
    dim l as short
    dim hfl as short
    dim hw as short
    dim lastspace as short
    dim tlen as short
    dim longest as short
    
    text=te
    help=he
    b=len(text)
    if loca=0 then loca=1
    c=0
    text=text &"/"
    do
        tlen=instr(text,"/")
        lines(c)=left(text,tlen-1)
        text=mid(text,tlen+1)
        c=c+1
    loop until len(text)<=0
    c=c-1
    if help<>"" then
        help=help &"/"
        hfl=1
        e=0
        b=len(help)
        do
            tlen=instr(help,"/")
            helps(e)=left(help,tlen-1)
            'if len(helps(e))>len(delhelp) then delhelp=space(len(helps(e)))
            help=mid(help,tlen+1)
            e=e+1
        loop until len(help)<=0
        e=0
    endif
    
    if loca>c then loca=c
    for a=0 to c
        shrt(a)=ucase(left(lines(a),1))
        if getdirection(shrt(a))>0 or val(shrt(a))>0 then shrt(a)=""
        if len(lines(a))>longest then longest=len(lines(a))
    next
    for a=0 to c
        lines(a)=lines(a)&space(longest-len(lines(a)))
    next
    hw=58-2-longest
    e=0
    do        
        locate y,x
        color 15,0
        print lines(0)
        
        for a=1 to c
            if loca=a then 
                if hfl=1 and loca<c then blen=textbox(helps(a),x+longest+2,2,hw,15,1)
                color 15,5
            else
                color 11,0
            endif
            locate y+a,x
            print lines(a)
        next
        key=keyin(,,blocked)
        
        if hfl=1 then 
            for a=2 to 2+blen
                locate 1+a,longest+x+2
                color 0,0
                print space(hw)
            next
        endif
        if getdirection(key)=8 then loca=loca-1
        if getdirection(key)=2 then loca=loca+1
        if loca<1 then loca=c
        if loca>c then loca=1
        if key=key_enter then e=loca
        if key=key_awayteam then 
            screenshot(1)
            showteam(0)
            screenshot(2)
        endif
        for a=0 to c
            if ucase(key)=shrt(a) and getdirection(key)=0 then loca=a
        next
        if key=key_esc or player.dead<>0 then e=c
    loop until e>0 
    color 0,0        
    for a=0 to c
        locate y+a,x
        print space(59)
    next
    color 11,0
    while inkey<>""
    wend
    return e
end function

function getrandomsystem(unique as short=1) as short 'Returns a random system. If unique=1 then specialplanets are possible
    dim as short a,b,c,p,u,add
    dim pot(laststar) as short
    for a=0 to laststar
        if map(a).discovered=0 and map(a).spec<8 then
            if unique=0 then
                add=0
                for u=0 to lastspecial
                    for p=1 to 9
                        if map(a).planets(p)=specialplanet(u) then add=1
                    next
                next
            endif
            if add=0 then
                pot(b)=a
                b=b+1
            endif
        endif
    next
    b=b-1
    if b>0 then 
        c=pot(rnd_range(0,b))
    else 
        c=-1
    endif
    return c
end function 


function getrandomplanet(s as short) as short
    dim pot(9) as short
    dim as short a,b,c
    if s>=0 and s<=laststar then
        for a=1 to 9
            if map(s).planets(a)>0 then
                pot(b)=map(s).planets(a)
                b=b+1
            endif
        next
        b=b-1
        if b=-1 then 
            c=-1
        else 
            c=pot(rnd_range(0,b))
        endif
    else
        c=-1
    endif
    return c
end function

function getdirection(key as string) as short
    dim d as short
    if key=key_south then return 2
    if key=key_north then return 8
    if key=key_east then return 6
    if key=key_west then return 4
    if key=key_nw then return 7
    if key=key_ne then return 9
    if key=key_se then return 3
    if key=key_sw then return 1
    if key=key_up then return 8
    if key=key_dn then return 2
    if key=key_rt then return 6
    if key=key_lt then return 4
    return 0
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

function getplanet(sys as short,forcebar as byte=0) as short
    dim a as short
    dim text as string
    dim key as string
    dim r as short 
    dim p as short
    dim x as short
    dim as short xo,yo
    dim firstplanet as short
    dim lastplanet as short
    if sys<0 or sys>laststar then
        dprint ("ERROR:System#:"&sys,14)
        return -1
    endif
    for a=1 to 9
        if map(sys).planets(a)<>0 then 
            lastplanet=a
            x=x+1
        endif
    next
    for a=9 to 1 step-1
        if map(sys).planets(a)<>0 then firstplanet=a
    next
    p=liplanet
    if p<1 then p=1
    if p>9 then p=9
    if map(sys).planets(p)=0 then 
        do
            p=p+1
            if p>9 then p=1
        loop until map(sys).planets(p)<>0 or lastplanet=0
    endif
    if p>9 then p=firstplanet
    if lastplanet>0 then
        if _onbar=0 or forcebar=1 then
            xo=31
            yo=22
        else
            xo=map(sys).c.x-9-player.osx
            yo=map(sys).c.y+2-player.osy
            if xo<=4 then xo=4
            if xo+18>58 then xo=42
        endif
        dprint "Enter to select, arrows to move,ESC to quit."
        if show_mapnr=1 then dprint map(sys).planets(p)&":"&isgasgiant(map(sys).planets(p))
        do
            displaysystem(map(sys))        
            if keyplus(key) or a=6 then 
                do
                    p=p+1
                    if p>9 then p=1
                loop until map(sys).planets(p)<>0
            endif
            if keyminus(key) or a=4 then 
                do
                    p=p-1
                    if p<1 then p=9
                loop until map(sys).planets(p)<>0
            endif
            if p<1 then p=lastplanet
            if p>9 then p=firstplanet
            x=xo+(p*2)
            if left(displaytext(25),14)<>"Asteroid field" or left(displaytext(25),15)<>"Planet at orbit" then dprint "System " &map(sys).desig &"."
            if map(sys).planets(p)>0 then
                if planets(map(sys).planets(p)).comment="" then
                    if isasteroidfield(map(sys).planets(p))=1 then
                        displaytext(25)= "Asteroid field at orbit " &p &"."
                    else
                        if planets(map(sys).planets(p)).mapstat<>0 then
                            if isgasgiant(map(sys).planets(p))<>0 then
                                if p>1 and p<7 then displaytext(25)= "Planet at orbit " &p &". A helium-hydrogen gas giant."
                                if p>6 then displaytext(25)= "Planet at orbit " &p &". A methane-ammonia gas giant."
                                if p=1 then displaytext(25)= "Planet at orbit " &p &". A hot jupiter."
                            else
                                if isgasgiant(map(sys).planets(p))=0 and isasteroidfield(map(sys).planets(p))=0 then displaytext(25)="Planet at orbit " &p &". " &atmdes(planets(map(sys).planets(p)).atmos) &" atm., " &planets(map(sys).planets(p)).grav &"g grav."
                                if len(displaytext(25))>60 then displaytext(25)=left(displaytext(25),60)
                            endif
                        else
                            displaytext(25)= "Planet at orbit " &p &"."
                        endif
                    endif
                endif
                if planets(map(sys).planets(p)).comment<>"" then
                    if isasteroidfield(map(sys).planets(p))=1 then
                        displaytext(25)= "Asteroid field at orbit " &p &": " &planets(map(sys).planets(p)).comment &"."
                    else
                        displaytext(25)= "Planet at orbit " &p &": " &planets(map(sys).planets(p)).comment &"."
                    endif
                endif
                dprint ""
                locate yo,x
                color 15,3
                if isgasgiant(map(sys).planets(p))=0 and isasteroidfield(map(sys).planets(p))=0 then print "o"
                if isgasgiant(map(sys).planets(p))>0 then print "O"
                if isasteroidfield(map(sys).planets(p))=1 then print chr(176)
                color 11,0
            endif
            
            if map(sys).planets(p)<0 then
                if map(sys).planets(p)<0 then
                    if isgasgiant(map(sys).planets(p))=0 then
                        displaytext(25)= "Asteroid field at orbit " &p &"."
                    else
                        if map(sys).planets(p)=-20001 then displaytext(25)= "Planet at orbit " &p &". A helium-hydrogen gas giant."
                        if map(sys).planets(p)=-20002 then displaytext(25)= "Planet at orbit " &p &". A methane-ammonia gas giant."
                        if map(sys).planets(p)=-20003 then displaytext(25)= "Planet at orbit " &p &". A hot jupiter."
                    endif
                    dprint ""
                endif
                locate yo,x
                color 15,3
                if isgasgiant(map(sys).planets(p))=0 then
                    print chr(176)
                else
                    print "O"
                endif
                color 11,0
            endif 
            key=keyin
            if key=key_comment then
                if map(sys).planets(p)>0 then
                    displaytext(25)= "Enter comment on planet: "
                    dprint ""
                    locEOL
                    planets(map(sys).planets(p)).comment=gettext(pos+1,csrlin-1,60,planets(map(sys).planets(p)).comment)
                else
                    displaytext(25)= "No comments allowed here."
                    dprint ""
                    sleep 2000
                    displaytext(25)= "Enter to select, arrows to move,ESC to quit."
                    dprint ""
                endif
            endif
            a=Getdirection(key)
            
            
            if key="q" or key="Q" or key=key_esc then r=-1
            if (key=key_enter or key=key_sc or key=key_la) and map(sys).planets(p)<>0 then r=p
        loop until r<>0
        liplanet=r
    else
        r=-1
    endif
    if len(displaytext(25))>60 then displaytext(25)=left(displaytext(25),60)
    return r
end function

function isgardenworld(m as short) as short
    if planets(m).grav>1.1 then return 0
    if planets(m).atmos<3 or planets(m).atmos>5 then return 0
    if planets(m).temp<-20 or planets(m).temp>55 then return 0
    if planets(m).weat>1 then return 0
    if planets(m).water<30 then return 0
    if planets(m).rot<0.5 or planets(m).rot>1.5 then return 0
    return -1
end function


function isgasgiant(m as short) as short
    if m<-20000 then return 1
    if m=specialplanet(21) then return 21
    if m=specialplanet(22) then return 22
    if m=specialplanet(23) then return 23
    if m=specialplanet(24) then return 24
    if m=specialplanet(25) then return 25
    if m=specialplanet(43) then return 43
    return 0
end function

function isasteroidfield(m as short) as short
    if m=specialplanet(31) then return 1 
    if m=specialplanet(32) then return 1 
    if m=specialplanet(33) then return 1
    if m=specialplanet(41) then return 1
    return 0
end function

function countasteroidfields(sys as short) as short
    dim as short a,b
    for a=1 to 9
        if map(sys).planets(a)<0 and isgasgiant(map(sys).planets(a))=0 then b=b+1
    next
    return b
end function


function countgasgiants(sys as short) as short
    dim as short a,b
    for a=1 to 9
        if isgasgiant(map(sys).planets(a))>0 then b=b+1
    next
    return b
end function

function checkcomplex(map as short,fl as short) as integer
    dim result as integer
    dim maps(36) as short
    dim as short nextmap,lastmap,foundport,a,b,done
    maps(0)=map
    do
    ' Suche portal auf maps(lastmap)
        lastmap=nextmap
        nextmap+=1
        for a=1 to lastportal
            if portal(a).from.m=maps(lastmap) then maps(nextmap)=portal(a).dest.m
        next
    loop until maps(nextmap)=0
    
    for a=1 to lastmap
        if maps(a)>0 and planets(maps(a)).genozide=0 then result+=1
    next
    return result
end function


function getnumber(a as short,b as short, e as short) as short
    dim key as string
    dim buffer as string
    dim c as short
    dim d as short
    dim i as short
    color 11,1
    for i=1 to 61
        locate 22,i
        print CHR(196)
    next
    color 11,11
    locate 22,28
    print space(5)
    c=a
    if e>0 then c=e
    do 
        locate 22,27
        color 11,1
        print chr(180)
        locate 22,28
        color 5,11
        print "-"

        if c<10 then 
            locate 22,30
            color 1,11
            print "0" &c
        else
            locate 22,29
            color 1,11
            print c
        endif
        
        locate 22,32
        color 5,11
        print "+"
        
        locate 22,33
        color 11,1
        print chr(195)
        key=keyin(key_up &key_dn &key_rt &key_lt &"1234567890+-"&key_esc &key_enter)
        if keyplus(key) then c=c+1
        if keyminus(key) then c=c-1
        if key=key_enter then d=1
        if key=key_esc then d=2
        buffer=buffer+key
        if len(buffer)>2 then buffer=""
        if val(buffer)<>0 then c=val(buffer)
        
        if c>b then c=b
        if c<a then c=a
        
    loop until d=1 or d=2
    if d=2 then c=-1
    color 11,0
    return c
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

function getshipweapon() as short
    dim as short a,b,c
    dim p(7) as short
    dim t as string
    t="Chose weapon/"
    for a=1 to 5
        if player.weapons(a).dam>0 then
            b=b+1
            p(b)=a
            t=t &player.weapons(a).desig & "/"
        endif
    next
    b=b+1
    p(b)=-1
    t=t &"Cancel"
    c=b-1
    if b>1 then c=p(menu(t))
    return c
end function


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

