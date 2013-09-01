function mudds_shop() as short
    dim as short a,b
    dprint "An overweight gentleman greets you 'Welcome to Mudds Incredible Bargains' Do you wish to buy or sell?"
    do
        display_ship
        a=menu(bg_parent,"Mudds Shop/Buy/Sell/Exit")
        if a=1 then 
            do
                b=shop(7,2.5,"Mudds Incredible Bargains")
                display_ship
            loop until b=-1
        endif
        if a=2 then buysitems("","",0,.1)
    loop until a=3 or a=-1
    return 0
end function

function sell_alien(sh as short) as short
    dim t as string
    dim as short i,c,biodata
    if lastcagedmonster=0 then
        dprint "You have nothing to sell."
        return 0
    endif
    do
        t="Sell liveform:"
        for i=1 to lastcagedmonster
            t=t &"/"&cagedmonster(i).sdesc
        next
        t=t & "/Exit"
        c=menu(bg_parent,t)
        if c>0 and c<=lastcagedmonster then
            biodata=get_biodata(cagedmonster(c))
            select case sh
            case slse_arena
                biodata=biodata*(cagedmonster(c).weapon+cagedmonster(c).armor)
            case slse_zoo
                biodata=biodata*1.1
            case slse_slaves
                if cagedmonster(c).lang>1 or (cagedmonster(c).intel>1 and cagedmonster(c).intel<5) then
                    biodata=cagedmonster(c).hpmax*cagedmonster(c).intel*cagedmonster(c).pumod/5
                else
                    biodata=0
                endif
            end select
            if biodata>0 then
                if askyn("I would give you "&credits(biodata)&"Cr. for your "&cagedmonster(c).sdesc &"(y/n)") then
                    addmoney(biodata,mt_piracy)
                    biodata=get_biodata(cagedmonster(c))
                    item(cagedmonster(c).c.s).v3-=biodata'Remove the biodata from the cage
                    reward(1)-=biodata
                    cagedmonster(c)=cagedmonster(lastcagedmonster)
                    lastcagedmonster-=1
                endif
            else
                dprint "I wouldn't know what to do with that."
            endif
            c=0
        endif
    loop until c=-1 or c=lastcagedmonster+1 or lastcagedmonster=0
    return 0
end function

function botsanddrones_shop() as short
    dim as integer a,b,c,il(lastitem),price
    dim as string wreckquestion
    price=15*haggle_("UP")
    do
    display_ship
    dprint "Welcome to the Bot-Bin! This sectors most sophisticated 2nd hand robot store."
    a=menu(bg_parent,"The Bot-bin/Buy/Sell/Exit")
    if a=1 then 
        do
            b=shop(25,0.8,"The Bot-bin")
            display_ship
        loop until b=-1
    endif
    if a=2 then
        if askyn("Always looking for spare parts we offer " &price & " Cr. for bot and rover debris. Do you want to sell? (y/n)") then
            for b=0 to lastitem
                if item(b).w.s<0 then
                    if item(b).id=65 then
                        c+=1
                        il(c)=b
                    endif
                endif
            next
            if c>0 then
                if c=1 then wreckquestion="You have "&c &" wreck. Do you want to sell them?(y/n)"
                if c>1 then wreckquestion="You have "&c &" wrecks. Do you want to sell them?(y/n)"
                if askyn(wreckquestion) then
                    addmoney(c*price,mt_quest2)
                    for b=1 to c
                        item(il(b)).w.s=99
                    next
                    for b=0 to lastitem
                        if item(b).w.s=99 then
                            item(b)=item(lastitem)
                            lastitem-=1
                        endif
                    next
                endif
            else
                dprint "You don't have any debris to sell."
            endif
        endif
    endif
    loop until a=3
    return 0
end function

function pay_bonuses(st as short) as short
    dim as integer a,tarval,debug,c
    dim as single factor
    for a=0 to 3
        if reward(a)>0 then c=1
    next
    if ano_money>0 then c=1
    if debug=1 and _debug=1 then dprint c &":"& basis(st).company+2
    if c=1 then combon(basis(st).company+2).value+=1
    combon(7).value=player.turn
    for a=0 to 8
        if a<3 or a>6 then
            tarval=combon(a).base*(combon(a).rank+1)^2
            if debug=1 and _debug=1 then dprint tarval &":"& combon(a).value
            if combon(a).value>=tarval and combon(c).rank<6 then
                combon(a).rank+=1
                factor=(combon(a).rank^2/2)*100
                If a=0 then dprint "For exploring "&(combon(a).value) &" planets you receive a bonus of "&credits(int(combon(a).rank*factor)) &" Cr.",11
                If a=1 then dprint "For recording biodata of "&credits(combon(a).value) &" aliens you receive a bonus of "&credits(int(combon(a).rank*factor)) &" Cr.",11
                If a=2 then dprint "For delivering "&credits(cint(reward(2)*basis(st).resmod*haggle_("up"))) &" Cr. worth of resources you receive a bonus of "&int(combon(a).rank*factor) &" Cr.",11
                If a=7 and combon(a).rank>1 then dprint "For continued business over "&(combon(a).value) &" time units you receive a bonus of "&credits(int(combon(a).rank*factor)) &" Cr.",11
                If a=8 then dprint "For destroying "&credits(combon(a).value) &" pirate ships you receive a bonus of "&int(combon(a).rank*factor) &" Cr.",11
                combon(a).value=0
                addmoney(int(combon(a).rank*factor),mt_bonus)
            endif
        endif
    next
    for a=3 to 6
        tarval=combon(a).base*(combon(a).rank+1)^2
        if debug=1 and _debug=1 then dprint tarval &":"& combon(a).value
    next
    
    if combon(3).value>1 and combon(4).value=0 and combon(5).value=0 and combon(6).value=0 then c=3
    if combon(3).value=0 and combon(4).value>1 and combon(5).value=0 and combon(6).value=0 then c=4
    if combon(3).value=0 and combon(4).value=0 and combon(5).value>1 and combon(6).value=0 then c=5
    if combon(3).value=0 and combon(4).value=0 and combon(5).value=0 and combon(6).value>1 then c=6
    if c>0 then
        if c=basis(st).company+2 then
            tarval=combon(c).base*(combon(c).rank+1)^2
            if combon(c).value>=tarval and combon(c).rank<6 then
                 combon(c).rank+=1
                 factor=(combon(a).rank^2/2)*100
                 dprint "For exclusively selling to " & companyname(basis(st).company) & " you receive a bonus of "& credits(int(combon(c).rank*100)) & "Cr.",15
                 addmoney(int(combon(c).rank*factor),mt_bonus)
           endif
        endif
    endif

    return 0
end function

    
function drawroulettetable() as short
    dim as short x,y,z
    dim coltable(36) as short
    coltable(0)=10
    coltable(1)=12
    coltable(2)=15
    coltable(3)=12
    coltable(4)=15
    coltable(5)=12
    coltable(6)=15
    coltable(7)=12
    coltable(8)=15
    coltable(9)=12
    coltable(10)=15
    coltable(11)=15
    coltable(12)=12
    coltable(13)=15
    coltable(14)=12
    coltable(15)=15
    coltable(16)=12
    coltable(17)=15
    coltable(18)=12
    coltable(19)=12
    coltable(20)=15
    coltable(21)=12
    coltable(22)=15
    coltable(23)=12
    coltable(24)=15
    coltable(25)=12
    coltable(26)=15
    coltable(27)=12
    coltable(28)=15
    coltable(29)=15
    coltable(30)=12
    coltable(31)=15
    coltable(32)=12
    coltable(33)=15
    coltable(34)=12
    coltable(35)=15
    coltable(36)=12

    z=0
    for y=1 to 12
        for x=1 to 3
            z=z+1
            locate y+2,x*3+45,0
            if coltable(z)=12 then
                set__color( 12,2)
            else
                set__color( 0,2)
            endif
            if z<10 then
                if x<3 then
                    draw string ((x*3+45)*_fw2,(y+2)*_fh2)," "&z &" ",,font2,custom,@_col
                else
                    draw string ((x*3+45)*_fw2,(y+2)*_fh2)," "&z,,font2,custom,@_col
                endif
            else
                if x<3 then
                    draw string ((x*3+45)*_fw2,(y+2)*_fh2),z &" ",,font2,custom,@_col
                else
                    draw string ((x*3+45)*_fw2,(y+2)*_fh2),""&z ,,font2,custom,@_col
                endif
            endif
        next
    next
    set__color( 15,0)
    return 0
end function

function upgradehull(t as short,byref s as _ship,forced as short=0) as short
    dim as short f,flg,a,b,cargobays,weapons,tfrom,tto,m
    dim n as _ship
    dim d as _crewmember
    dim as string ques
    dim as string word(10)
    dim as string text
    if t<20 then
        n=gethullspecs(t,"data/ships.csv")
    else
        n=gethullspecs(t-22,"data/customs.csv")
    endif
    for a=1 to 10
        if s.cargo(a).x>0 then cargobays=cargobays+1
        if s.weapons(a).desig<>"" then weapons=weapons+1
    next
    
    'compare
    if s.h_maxhull>n.h_maxhull then ques=ques &"The new ship will have a lower maximum armor capacity than your current one. "
    if s.engine>n.h_maxengine and s.engine<6 then ques=ques &"You will need to downgrade your engine for the new hull. "
    if s.shieldmax>n.h_maxshield then ques=ques &"You will need to downgrade your shield generators for the new hull."
    if s.sensors>n.h_maxsensors and s.sensors<6 then ques=ques &"You will need to downgrade your sensors for the new hull."
    if cargobays>n.h_maxcargo then ques=ques &"The new ship will have less cargo space. "
    if s.h_maxcrew>n.h_maxcrew then ques=ques &"The new ship will have less space for crewmen. "
    if s.h_maxweaponslot>n.h_maxweaponslot then ques=ques &"The new ship will have fewer weapon turrets. "
    if s.h_maxfuel>n.h_maxfuel then ques=ques &"The new ship will have a lower fuel capacity than your current one."
    if forced=1 then
        ques=""
        flg=-1
    endif
    if ques<>"" then
        dprint ques,14 
        if askyn("Do you really want to transfer to the new hull?") then 
            flg=-1
        else
            flg=0
        endif
    else
        flg=-1
    endif
    if flg=-1 then
        s.ti_no=n.h_no
        if s.ti_no=18 then s.ti_no=17 'ASCS is one step lower
        if s.ti_no>18 then s.ti_no=9
        s.h_no=n.h_no
        s.h_price=n.h_price
        s.h_desig=n.h_desig
        s.h_sdesc=n.h_sdesc
        s.h_maxhull=n.h_maxhull
        s.h_maxengine=n.h_maxengine
        s.h_maxsensors=n.h_maxsensors
        s.h_maxshield=n.h_maxshield
        s.h_maxcargo=n.h_maxcargo
        s.h_maxcrew=n.h_maxcrew
        if s.engine<6 and s.engine>s.h_maxengine then s.engine=s.h_maxengine
        if s.sensors<6 and s.sensors>s.h_maxsensors then s.sensors=s.h_maxsensors
        if s.shieldmax>s.h_maxshield then s.shieldmax=s.h_maxshield
        
        s.h_maxweaponslot=n.h_maxweaponslot
        s.h_maxfuel=n.h_maxfuel
        if s.hull=0 then s.hull=s.h_maxhull*0.8
        if s.hull>s.h_maxhull then s.hull=s.h_maxhull
        if s.fuel=0 or s.fuel>s.h_maxfuel then s.fuel=s.h_maxfuel
        if s.h_maxweaponslot<weapons then
            poolandtransferweapons(n,s)
'            do
'                tfrom=(s.h_maxweaponslot -tto)
'                text="Chose weapons to transfer ("&tfrom &"):"
'                b=1
'                for a=1 to 10
'                    if s.weapons(a).desig<>"" then 
'                        text=text &"/"&s.weapons(a).desig
'                        b=b+1
'                    endif
'                next
'                text=text &"/Exit"
'                a=menu(text)
'                if a<b then
'                    tto=tto+1
'                    n.weapons(tto)=s.weapons(a)
'                    dprint "Transfering "&s.weapons(a).desig &" to slot "&tto
'                    weapons=weapons-1
'                endif
'                if a=b then
'                    if not(askyn("Do you really want to lose your remaining weapons(y/n)?")) then a=0
'                endif
'            loop until a=b or tto=s.h_maxweaponslot
'            for a=0 to 10
'                s.weapons(a)=n.weapons(a)
'            next
        endif
        
        recalcshipsbays
        
        if s.security>s.h_maxcrew+player.crewpod+player.cryo then
            s.security=s.h_maxcrew
            for a=s.h_maxcrew+player.crewpod+player.cryo to 128
                crew(a)=d
            next
        endif
        s.fuelmax=s.h_maxfuel+s.fuelpod
    endif
    return flg
end function

function findcompany(c as short) as short
    dim a as short
    for a=0 to 2
        if basis(a).company=c then return 1
    next
    return 0
end function

function company(st as short) as short
    dim as short b,c,q,complete
    dim m as integer
    dim as single a
    dim as string s,k
    dim towed as _ship
    dim p as _cords
    display_ship(0)
    m=player.money
    if configflag(con_autosale)=0 then q=-1
    dprint "you enter the administrator's office"                    
    reward_bountyquest(0)
    if player.questflag(1)=1 then
        if basis(st).repname="Omega Bioengineering" then
            a=25000
        else
            a=15000
        endif
        if askyn("The Rep offers to buy your data on the ancients pets for "&credits(a) &" Cr. Do you accept?(y/n)") then
            addmoney(a,mt_artifacts)
            player.questflag(1)=2
            if a=25000 then player.questflag(1)=3
        endif
        a=0
    endif
    if player.questflag(2)=2 then
        dprint "The Company Rep congratulates you on a job well done and pays you 15,000 Cr.",10
        factionadd(0,1,-15)
        addmoney(15000,mt_quest)
        player.questflag(2)=4
        no_key=keyin
    endif
    if player.questflag(2)=3 then
        dprint "The Company Rep congratulates you on a job well done and pays you 10,000 Cr.",10
        factionadd(0,1,-15)
        addmoney(10000,mt_quest)
        player.questflag(2)=4
        no_key=keyin
    endif
    if player.questflag(3)=1 then
        dprint "After some negotiations you convince the company rep to buy the secret of controling the alien ships for ... 1,000,000 CR!",10
        factionadd(0,1,-15)
        addmoney(1000000,mt_artifacts)
        player.questflag(3)=2
        no_key=keyin
    endif
    if player.questflag(5)=2 then
        dprint "The Company Rep congratulates you on a job well done and pays you 15,000 Cr.",10
        factionadd(0,1,-15)
        addmoney(15000,mt_quest)
        player.questflag(5)=3
        no_key=keyin
    endif 
    if player.questflag(6)=2 then
        dprint "The Company Rep congratulates you on a job well done and pays you 15,000 Cr.",10
        factionadd(0,1,-15)
        addmoney(15000,mt_quest)
        player.questflag(6)=3
        no_key=keyin
    endif
    if player.questflag(7)>0 and basis(st).company=1 and planets(player.questflag(7)).flags(21)=1 then
        addmoney(1000,mt_map)
        factionadd(0,1,-15)
        dprint "The company rep pays your 1,000 Cr. contract for mapping the planet",10
        player.questflag(7)=0
    endif
    if player.questflag(9)=2 and basis(st).company=2 then 
        addmoney(5000,mt_artifacts)
        factionadd(0,1,-15)
        dprint "The company rep pays your 5,000 Cr. contract for finding a robot factory.",10
        player.questflag(9)=3
    endif
    if player.questflag(10)<0 and basis(st).company=4 then
        addmoney(2500,mt_quest)
        factionadd(0,1,-15)
        dprint "The company rep pays you 2,500 Cr. for finding a planet to conduct their experiment on.",10
        planetmap(rnd_range(0,60),rnd_range(0,20),abs(player.questflag(10)))=16
        player.questflag(10)=0
    endif
    if player.questflag(11)=2 then 
        addmoney(5000,mt_quest)
        factionadd(0,1,-15)
        dprint "The company rep remarks that these crystal creatures could be a threat to colonizing this sector and pays you your reward of 5,000 Cr.",10
        player.questflag(11)=3
    endif
    if player.questflag(12)=0 and checkcomplex(specialplanet(33),1)=4 then 
        player.questflag(12)=1
        factionadd(0,1,-15)
        addmoney(10000,mt_quest)
        dprint "The company rep pays you 10,000 Cr. for destroying the pirates asteroid hideout.",10
    endif
    
    if player.questflag(15)=2 then 
        player.questflag(15)=3
        factionadd(0,1,-15)
        addmoney(10000,mt_pirates)
        dprint "The company rep pays you 10,000 Cr. for destroying the pirate Battleship 'Anne Bonny'.",10
    endif
    
    if player.questflag(16)=2 then 
        player.questflag(16)=3
        factionadd(0,1,-15)
        addmoney(8000,mt_pirates)
        dprint "The company rep pays you 8,000 Cr. for destroying the pirate Destroyer 'Black corsair'.",10
    endif
    
    if player.questflag(17)=2 then 
        player.questflag(17)=3
        factionadd(0,1,-15)
        addmoney(5000,mt_pirates)
        dprint "The company rep pays you 5,000 Cr. for destroying the pirate Cruiser 'Hussar'.",10
    endif
    
    if player.questflag(18)=2 then 
        player.questflag(18)=3
        factionadd(0,1,-15)
        addmoney(2500,mt_pirates)
        dprint "The company rep pays you 2,500 Cr. for destroying the pirate fighter 'Adder'.",10
    endif
    
    if player.questflag(19)=2 then 
        player.questflag(19)=3
        factionadd(0,1,-15)
        addmoney(2500,mt_pirates)
        dprint "The company rep pays you 2,500 Cr. for destroying the pirate fighter 'Widow'.",10
    endif
    
    for a=0 to lastitem
        if item(a).w.s=-1 and item(a).ty=47 and item(a).v1>1 then 
            if item(a).v2=0 then
                dprint "The relatives of the spacer who's ID-tag you found put a reward of " & credits(item(a).v1*20) &" credits on any information on his wereabouts."
                addmoney(item(a).v1*20,mt_quest)
            else
                dprint "At least now we know. Here is your reward."
                addmoney(500,mt_quest)
                player.questflag(26)=0
            endif
            destroyitem(a)
        endif
    next
    
    if player.questflag(21)=1 then
        if basis(st).company=1 then
            if askyn("Do you want to blackmail Eridiani Explorations with your information on their Drug business?(y/n)") then
                factionadd(0,1,1)
                addmoney(1000,mt_blackmail)
                companystats(1).capital=companystats(1).capital-rnd_range(1,100)
                dprint "The Rep pays 1,000 Cr. for your Silence"
            endif
        else
            if askyn("Do you want to sell "&companyname(basis(st).company) &" the secret of Eridiani Explorations Drug business?(y/n)") then
                dprint "The Rep pays 10,000 Cr. for your the information"
                companystats(1).capital=companystats(1).capital-500
                player.questflag(21)=2
                addmoney(10000,mt_blackmail)
            endif
        endif
    endif
    
    
    if player.questflag(22)=1 then
        if basis(st).company=2 then
            if askyn("Do you want to blackmail Smith Heavy Industries with your information on their slave work?(y/n)") then
                factionadd(0,1,1)
                addmoney(1000,mt_blackmail)
                companystats(2).capital=companystats(2).capital-rnd_range(1,100)
                dprint "The Rep pays 1,000 Cr. for your Silence"
            endif
        else
            if askyn("Do you want to sell "&companyname(basis(st).company) &" the secret of Smith Heavy Industries slave business?(y/n)") then
                dprint "The Rep pays 10,000 Cr. for your the information"
                companystats(2).capital=companystats(2).capital-500
                player.questflag(22)=2
                addmoney(10000,mt_blackmail)
            endif
        endif
    endif
    
    if player.questflag(23)=2 then
        if basis(st).company=3 then
            if askyn("Do you want to blackmail Triax Traders with your information on their agreement with pirates?(y/n)") then
                factionadd(0,1,1)
                addmoney(1000,mt_blackmail)
                companystats(3).capital=companystats(3).capital-rnd_range(1,100)
                dprint "The Rep pays 1,000 Cr. for your Silence"
            endif
        else
            if askyn("Do you want to sell "&companyname(basis(st).company) &" your information on Triax Traders agreement with pirates?(y/n)") then
                dprint "The Rep pays 10,000 Cr. for your the information"
                companystats(3).capital=companystats(3).capital-500
                player.questflag(23)=3
                addmoney(10000,mt_blackmail)
            endif
        endif
    endif
    
    if player.questflag(24)=1 then
        if basis(st).company=4 then
            if askyn("Do you want to blackmail Omega Bioengineering with your information on their experiments?(y/n)") then
                factionadd(0,1,1)
                addmoney(1000,mt_blackmail)
                companystats(4).capital=companystats(4).capital-rnd_range(1,100)
                dprint "The Rep pays 1,000 Cr. for your Silence"
            endif
        else
            if askyn("Do you want to sell "&companyname(basis(st).company) &" the secret of Omega Bioengineerings experiments?(y/n)") then
                dprint "The Rep pays 10,000 Cr. for your the information"
                companystats(4).capital=companystats(4).capital-500
                player.questflag(24)=2
                addmoney(10000,mt_blackmail)
            endif
        endif
    endif
    
    if specialflag(31)=1 then
        if askyn("The company rep is fascinated about your report on the ancient space station in the asteroid belt. He offers you 75,000 Credits for the coordinates. Do you accept?(y/n)") then
            addmoney(75000,mt_quest)
            a=sysfrommap(specialplanet(31))
            factionadd(0,1,-25)
            basis(4)=makecorp(0)
            basis(4).discovered=1
            basis(4).c=map(a).c
            fleet(5).c=map(a).c
            for b=1 to 9
                if map(a).planets(b)=specialplanet(31) then map(a).planets(b)=-rnd_range(1,8)
            next
            specialflag(31)=2
        endif
    endif 
    
    if artflag(21)=1 then
        if askyn("The company is highly interested in buying the specs on neutronium hulls. They offer 10.000 Cr.(y/n)") then 
            artflag(21)=2
            addmoney(10000,mt_artifacts)
        endif
    endif
    
    if artflag(22)=1 then
        if askyn("The company is highly interested in buying this new technology for quantum warheads. Do you want to sell it for 10.000 Cr.? (y/n)") then
            artflag(22)=2
            addmoney(10000,mt_artifacts)
        endif
    endif
    
    if findbest(24,-1)>0 then
        b=findbest(24,-1)
        if item(b).v5 mod 10=0 then
            dprint "The company Rep is highly interested in buying that portable nanobot factory. He offers you "&credits((50000+100*item(b).v5)*basis(st).biomod) &" credits."
            if askyn("Accept(y/n)") then
                factionadd(0,1,-35)
                addmoney((50000+100*item(b).v5)*basis(st).biomod,mt_artifacts)
                destroyitem(findbest(24,-1))
            else
                dprint "The offer stands."
            endif
        else
            item(b).v5+=1
            if item(b).v5>500 then item(b).v5=491
        endif
    endif    
    
    if findbest(87,-1)>0 and basis(st).company=4 then
        if askyn("The company rep would buy the burrowers eggsacks for 100 Credits a piece. Do you want to sell?(y/n)") then
            for a=0 to lastitem
                if item(a).ty=87 and item(a).w.s=-1 then 
                    destroyitem(a)
                    addmoney(100,mt_bio)
                endif
            next
        endif
    endif
    
    if basis(st).company=2 then
        c=0
        for a=1 to lastplanet
            if planets(a).flags(23)=2 then c=a
        next
        if c>0 then
            dprint "Thanks for helping wiping out those pirates!"
            planets(c).flags(23)=3
            addmoney(2500,mt_pirates)
        endif
    endif
    
    if player.towed<>0 then
        if player.towed>0 then
            towed=gethullspecs(drifting(player.towed).s,"data/ships.csv")
            a=towed.h_price
            if planets(drifting(player.towed).m).genozide<>1 then a=a/2
            a=a/2
            a=int(a)
            if planets(drifting(player.towed).m).mon_template(0).made<>32 then
                if askyn ("the company offers you "& credits(a) &" Cr. for the "&towed.h_desig &" you have in tow. Do you accept?(y/n)") then
                    drifting(player.towed)=drifting(lastdrifting)
                    lastdrifting-=1
                    addmoney(a,mt_towed)
                    player.towed=0
                endif
            else
                a=disnbase(drifting(player.towed).start)
                a=int(a*100)
                dprint "The company pays you "&credits(a) &" Cr. for towing in the ship."
                drifting(player.towed)=drifting(lastdrifting)
                lastdrifting-=1
                addmoney(a,mt_towed)
                player.towed=0
            endif
        endif
        a=0
    endif
            
    c=0
    for b=0 to 4
        c=c+reward(b)
    next
    c=c+ano_money
    if c=0 then 
        dprint "You have nothing to sell to "& basis(st).repname
    else
        companystats(basis(st).company).profit=companystats(basis(st).company).profit+c
        dprint basis(st).repname &":"
        factionadd(1,0,1)
    endif
    
    if questroll<33 then questroll=give_quest(st)    
    
    if reward(0)>1 then
        if configflag(con_autosale)=1 then q=askyn("do you want to sell map data? (y/n)")
        for a=0 to laststar
            for b=1 to 9
                if map(a).planets(b)>0 then
                    if planets(map(a).planets(b)).flags(21)=1 then
                        complete+=1
                        planets(map(a).planets(b)).flags(21)=2
                    endif
                endif
            next
        next
        if q=-1 and basis(st).repname="Eridiani Explorations" then
            if complete>1 then dprint "Eridiani explorations pays "&credits(complete*50) &" Cr. for the complete maps of "&complete &"planets"
            if complete=1 then dprint "Eridiani explorations pays "&credits(complete*50) &" Cr. for the complete map of a planet"
            addmoney(complete*50,mt_map)
        endif
        
        if q=-1 then
            if cint((reward(7)/15)*basis(st).mapmod*haggle_("up"))>0 then
                dprint "you transfer new map data on "&reward(0)&" km2. you get paid "&credits(cint((reward(7)/15)*basis(st).mapmod*haggle_("up")))&" Cr."
                addmoney(cint((reward(7)/15)*basis(st).mapmod*haggle_("up")),mt_map)
            endif
            reward(0)=0
            reward(7)=0
            k=keyin
        endif
    endif
    
    pay_bonuses(st)
    
    if reward(1)>0 then
        if configflag(con_autosale)=1 then q=askyn("do you want to sell bio data? (y/n)")
        if q=-1 then
            if lastcagedmonster=0 then
                dprint "you transfer data on alien lifeforms worth "& credits(cint(reward(1)*basis(st).biomod*(1+0.1*crew(1).talents(2)))) &" Cr."
            else
                dprint "you transfer data on alien lifeforms and " &lastcagedmonster & " live specimen worth "& credits(cint(reward(1)*basis(st).biomod*(1+0.1*crew(1).talents(2)))) &" Cr."
            endif
            addmoney((reward(1)*basis(st).biomod*haggle_("up")),mt_bio)
            reward(1)=0
            lastcagedmonster=0
            for a=0 to lastitem
                if item(a).ty=26 and item(a).w.s<0 then 
                    item(a).v1=0 'Empty cages
                    item(a).ldesc="For trapping wild animals. Just place it on the ground and wait for an animal to wander into it. Contains:"
                endif
                if item(a).ty=29 and item(a).w.s<0 then item(a).v1=0
            next
            k=keyin
        endif
    endif
    if reward(2)>0 then
        if configflag(con_autosale)=1 then q=askyn("do you want to sell resources? (y/n)")
        if q=-1 then
            dprint "you transfer resources for "& credits(cint(reward(2)*basis(st).resmod*(1+0.1*crew(1).talents(2)))) &" Cr."
            addmoney(cint(reward(2)*basis(st).resmod*(1+0.1*crew(1).talents(2))),mt_ress)
            reward(2)=0
            destroy_all_items_at(15,-1)
            k=keyin
        endif
    endif
    if reward(3)>0 then
        if configflag(con_autosale)=1 then q=askyn("do you want to collect your bounty for destroyed pirate ships? (y/n)")
        if q=-1 then
            dprint "You recieve "&credits(cint(reward(3)*basis(st).pirmod*(1+0.1*crew(1).talents(2)))) &" Cr. as bounty for destroyed pirate ships."
            addmoney(cint(reward(3)*basis(st).pirmod*(1+0.1*crew(1).talents(2))),mt_pirates)
            reward(3)=0
            no_key=keyin
        endif
    endif
    if ano_money>0 then
        if configflag(con_autosale)=1 then q=askyn("do you want to sell your information on wormholes and anomalies? (y/n)")
        if q=-1 then
            if basis(st).company=3 then ano_money=cint(ano_money*1.5)
            dprint "You recieve "&credits(ano_money) &" credits for your information on wormholes and anomalies."
            addmoney(ano_money,mt_ano)
            ano_money=0
        endif
    endif
    if reward(4)>0 then
        if configflag(con_autosale)=1 then q=askyn("do you want to sell your artifacts? (y/n)")
        if q=-1 then
            m=0
            for a=1 to reward(4) 
                m+=(rnd_range(1,3)+rnd_range(1,3))*1000
            next
            if m<0 then m=2147483647
            dprint basis(st).repname &" pays " &credits(m) &" credits for the alien curiosity"
            addmoney(m,mt_artifacts)
            reward(4)=0
            no_key=keyin
        endif
    endif
    if reward(6)>1 then
        dprint "The Company pays you 50,000 Cr. for eliminating the pirate threat in this sector!"
        addmoney(50000,mt_pirates)
        reward(6)=-1
        no_key=keyin
    endif
    if reward(8)>0 then
        dprint "The Company pays "&credits(reward(8)) &" Cr. for destroying pirate outposts"
        addmoney(reward(8),mt_pirates)
        reward(8)=0
        no_key=keyin
    endif
    
    ask_alliance(1)
    
    dprint "you leave the company office"
    if m<0 and player.money>0 then factionadd(0,1,-1)
    return 0
end function

function casino(staked as short=0, st as short=-1) as short
    dim as short a,b,c,d,e,f,pr,bet,num,fi,col,times,mbet,gpld,asst,x,y,z,t,price,bonus,passenger,i
    dim ba(3) as short
    dim localquestguy(lastquestguy+4) as short
    dim leave as short
    dim as uinteger mwon,mlos
    dim as integer result
    dim as string text,menustring
    dim p as _cords
    dim coltable(36) as short
    dim qgindex(15) as short
    dim as short debug
    dim as string randomgender
    if rnd_range(1,100)<50 then
        randomgender="he"
    else
        randomgender="her"
    endif
    
    debug=1
    
    coltable(0)=10
    coltable(1)=12
    coltable(2)=15
    coltable(3)=12
    coltable(4)=15
    coltable(5)=12
    coltable(6)=15
    coltable(7)=12
    coltable(8)=15
    coltable(9)=12
    coltable(10)=15
    coltable(11)=15
    coltable(12)=12
    coltable(13)=15
    coltable(14)=12
    coltable(15)=15
    coltable(16)=12
    coltable(17)=15
    coltable(18)=12
    coltable(19)=12
    coltable(20)=15
    coltable(21)=12
    coltable(22)=15
    coltable(23)=12
    coltable(24)=15
    coltable(25)=12
    coltable(26)=15
    coltable(27)=12
    coltable(28)=15
    coltable(29)=15
    coltable(30)=12
    coltable(31)=15
    coltable(32)=12
    coltable(33)=15
    coltable(34)=12
    coltable(35)=15
    coltable(36)=12
    if st=-1 then 'More passengers outside of stations
        passenger=-30
    else
        passenger=0
    endif
    bg_parent=bg_noflip
    
    screenset 1,1
    do
        menustring="Casino:/Play Roulette/Play Slot Machine/Play Poker/Have a drink/"
        leave=5
        for i=1 to lastquestguy
            if questguy(i).location=st then
                questguy(i).lastseen=st 'For the quest log
                localquestguy(leave)=i
                if debug=1 and _debug=1 then menustring=menustring &st &"(W:"&questguy(i).want.type &" H:" &questguy(i).has.type &")"
                menustring=menustring & questguyjob(questguy(i).job) &" "&questguy(i).n &"/"
                qgindex(leave)=i
                leave+=1
            endif
        next
        menustring=menustring &"Leave"
        cls
        display_ship(0)
        drawroulettetable()
        a=menu(bg_parent,menustring)
        if a=1 then
        do 
            drawroulettetable()
            b=menu(bg_roulette,"Roulette:/Bet on Number/Bet on Pair/Bet on Impair/Bet on Rouge/Bet on Noir/Don't play")
            if b<>6 then 
                drawroulettetable()
                if b=1 then 
                    dprint "which number?"
                    fi=getnumber(1,36,18)
                endif
                if player.money>50+staked*50 then 
                    mbet=50+staked*50
                else
                    mbet=player.money
                endif
                dprint "how much? (0-"& mbet &")"
                bet=getnumber(0,mbet,0)
                player.money=player.money-bet
                display_ship()
                if bet>0 then
                    changemoral(bet/3,0)
                    locate 14,25
                    dprint "Rien Ne va plus "
                    for d=1 to rnd_range(1,6)+10
                        num=rnd_range(0,36)
                        col=coltable(num)
                        set__color( col,0)
                        Draw string (15*_fw1,10*_fh1)," "&num &" ",,font2,custom,@_col
                        sleep d*d*2
                    next
                    if staked=1 then
                        if gpld<10 then
                            if b=1 then num=fi
                            if b=2 and frac(num/2)<>0 then 
                                num=num+1
                                if num>36 then num=36
                            endif
                            if b=3 and frac(num/2)=0 then 
                                num=num+1
                            endif
                            if b=4 and coltable(num)=15 then
                               do 
                                   num=rnd_range(0,36)
                               loop until coltable(num)=12
                            endif
                            if b=5 and coltable(num)=12 then 
                                do 
                                   num=rnd_range(0,36)
                               loop until coltable(num)=15
                            endif
                        else
                            if b=1 and num=fi then num=num+1
                            if b=2 and frac(num/2)<>0 then 
                                num=num+1
                                if num>36 then num=36
                            endif
                            if b=3 and frac(num/2)<>0 then 
                                num=num+1
                            endif
                            if b=4 and coltable(num)=12 then
                               do 
                                   num=rnd_range(0,36)
                               loop until coltable(num)=15
                            endif
                            if b=5 and coltable(num)=15 then 
                                do 
                                   num=rnd_range(0,36)
                               loop until coltable(num)=12
                            endif
                        endif
                        col=coltable(num)
                        set__color( col,0)
                        Draw string (15*_fw1,10*_fh1)," "&num &" ",,font2,custom,@_col
                        sleep d*d*2
                    endif
                    if crew(1).talents(5)=1 then
                        if b=1 and fi<>num then num=rnd_range(0,36)
                        if b=2 and frac(num/2)<>0 then num=rnd_range(0,36)
                        if b=3 and frac(num/2)=0 then num=rnd_range(0,36)
                        if b=4 and coltable(num)=15 then num=rnd_range(0,36)
                        if b=5 and coltable(num)=12 then num=rnd_range(0,36)                        
                        col=coltable(num)
                        set__color( col,0)
                        Draw string (15*_fw1,10*_fh1)," "&num &" ",,font2,custom,@_col
                        sleep d*d*2
                    endif
                    times=0
                    if num=0 then dprint "Bank wins"
                    if b=1 and fi=num then times=35
                    if b=2 and frac(num/2)=0 then times=2
                    if b=3 and frac(num/2)<>0 then times=2
                    if b=4 and coltable(num)=12 then times=2
                    if b=5 and coltable(num)=15 then times=2
                    if times>0 then
                        dprint "you win " & credits(bet*times) & " Credits!"
                        addmoney(bet*times,mt_gambling)
                        mwon=mwon+bet*times
                    else
                        dprint "You lose"
                        mlos=mlos+bet
                    endif
                    gpld=gpld+1
                endif
                
            endif
            display_ship
            drawroulettetable()
            if b=6 and staked=1 then
                drawroulettetable()
                if gpld<3 or mwon>mlos then 
                    if asst<5 then
                        dprint "cmon, play another one"
                        b=0
                        asst=asst+1
                    endif
                else
                    if askyn("I am sure your luck will return! do you really want to leave?(y/n)") then
                       b=6
                       gpld=2
                    else
                        dprint "good decision!"
                        b=0
                    endif
                endif
            endif
            loop until b=6
        endif
        if a=2 then play_slot_machine
        if a=3 then 
            do
                play_poker(st)
            loop until not(askyn("Do you want to play another hand?(y/n)"))
        endif
        if a=4 then
            drawroulettetable()
            if not paystuff(1) then                 
                dprint "you can't even afford a drink."
                if rnd_range(1,100)<20 and player.money>=-4 then 
                    dprint "The barkeep has pity and hands you 5 credits to bet at the roulette table."
                    player.money+=5
                endif
            else
                dprint "you have a drink."
                changemoral(1,0)
            endif
            if rnd_range(1,100)<25-passenger then 'Passenger
                b=rnd_range(0,2)
                passenger+=5
                if b<>st then
                    t=player.turn+(rnd_range(15,25)/10)*distance(player.c,basis(b).c)
                    price=distance(player.c,basis(b).c)*rnd_range(1,20)
                    bonus=rnd_range(1,15)
                    if askyn("A passenger needs to get to space station "& b+1 &" by turn "& t &". He offers you "&price &" Cr, and a "& bonus &" Cr. Bonus for every turn you arrive there earlier. Do you want to take him with you?(y/n)") then
                        if max_security>0 then
                            add_passenger("Passenger for S-"& b+1,30,price,bonus,b+1,t,0)
                        else
                            dprint "You don't have room to take him with you."
                        endif
                    endif
                endif
            endif
            if rnd_range(1,100)<66 and player.money>=0 then
                if BonesFlag>0 and planets(Bonesflag).visited=0 then
                    b=rnd_range(1,45)
                    if rnd_range(1,30)<100 then b=1001
                else
                    b=rnd_range(1,45)
                endif
                c=rnd_range(0,2)
                d=rnd_range(1,5)
                if faction(0).war(1)>50 or income(mt_trading)/player.money>0.5 then 
                    if basis(st).spy=0 and rnd_range(1,100)<25 and st>-1 then b=100
                    if income(mt_trading)=0 and faction(0).war(1)<51 then b=rnd_range(1,39)
                endif
                p=fleet(rnd_range(1,lastfleet)).c
                if p.x=0 and p.y=0 then p=rnd_point
                if b=16 and rnd_range(1,100)<66 then p=map(piratebase(rnd_range(0,_NoPB))).c
                if b=1 then dprint "An old miner tells you a tall tale about a planet he worked on. Short version: they dug too deep and released invisible monsters that drove them off the planet."
                if b=2 then dprint "Another prospector tells you that he used ground radar to locate the ruins of an alien temple. Unfortunately the weather on the planet was so harsh his crew muntinied and demanded to return to the station immediately."
                if b=3 then dprint "A merchant captain claims to have outrun the infamous 'Anne Bonny' at coordinates "&cords(p)&"."
                if b=4 then dprint "A patrol captain claims to have shot down the infamous 'Anne Bonny' at coordinates "&cords(p)&"."
                if b=5 then dprint "Your science officer finds no drinks he hasnt seen yet."
                if b=6 then dprint "Your pilot wants to leave."
                if b=7 then dprint "Your gunner thinks the owners could put up a dartboard here for practice."
                if b=8 then dprint "A lone drunk informs you that the roulette wheel is rigged! He then asks you to buy him a drink."
                if b=9 then dprint "A scoutship captain claims to have found a lutetium deposit at coordinates "&rnd_range(1,59) &":" &rnd_range(1,19) &" that was too large to load into his ship."
                if b=10 then dprint "A security team member tells you a tall tale about fighting alien robots in an ancient city ruin 'They aren't gone. they are sleeping is what i say!'"
                if b=11 then dprint "Another prospector and a patrol ship captain are discussing an incident on a planet at coordinates "&rnd_range(1,59) &":" &rnd_range(1,19) &". Two freelance prospectors had landed on it at the same time and got into a dispute over a palladium deposit. The patrol captain remarks that 'those guys should be taught a lesson'" 
                if b=12 then dprint "A young man shows pictures of his brother. He was last seen on Station "&rnd_range(1,3)&", leaving with a scoutship, and hasn't returned."
                if b=13 then dprint "you get told that the weather in the stations hydroponic garden was remarkably pleasant lately!"
                if b=14 then dprint "you learn that the view from port E on the 5th ring of the station is spectacular"
                if b=15 then dprint "You hear a story about an ancient robot ship prowling the sector, attacking everything on sight. The Anne Bonny is said to have escaped it once. Everything else is destroyed."
                if b=16 then dprint "A patrolboat captain claims to have fought a big pirate fleet at coordinates "&cords(p) &"."
                if b=17 then dprint "A light transport captain claims in a discussion on traderoutes that the average price for  "& goodsname(1) &" is "&avgprice(1) &"."
                if b=18 then dprint "A Merchantman captain claims in a discussion on traderoutes that the average price for  "& goodsname(2) &" is "&avgprice(2) &"."
                if b=19 then dprint "A heavy transport captain claims in a discussion on traderoutes that the average price for  "& goodsname(3) &" is "&avgprice(3) &"."
                if b=20 then dprint "A Merchantman captain claims in a discussion on traderoutes that the average price for  "& goodsname(4) &" is "&avgprice(4) &"."
                if b=21 then dprint "A armed merchantman captain claims in a discussion on traderoutes that the average price for  "& goodsname(5) &" is "&avgprice(5) &"."
                if b=22 and st<>c then dprint "In a discussion about traderoutes a heavy transport captain claims that at station "& c+1 &" the price for  "& goodsname(d) &" is "& basis(c).inv(d).p &"."
                if b=23 and st<>c then dprint "In a discussion about traderoutes a light transport captain claims that at station "& c+1 &" the price for  "& goodsname(d) &" is "& basis(c).inv(d).p &"."
                if b=24 and st<>c then dprint "In a discussion about traderoutes a merchantman captain claims that at station "& c+1 &" the there is a  "& basis(c).inv(d).v &" ton stock of "& goodsname(d) &"."
                if b=25 and st<>c then dprint "In a discussion about traderoutes a armed merchantman captain claims that at station "& c+1 &" the there is a  "& basis(c).inv(d).v &" ton stock of "& goodsname(d) &"."
                if b=26 then dprint "Another prospector tells you that there is a rumor about a planet whith immortal inhabitants."
                if b=27 then dprint "A science officer tells you that most animals on earth live for about 5 million heartbeats. 'Life expectancy is mainly a function of metabolism. A mouse just uses them up a little faster than an elephant.'"
                if b=28 then dprint "A scout captain tells you that he went refueling on a gas giant when his sensors picked up a huge metallic structure. He decided discretion was the better part of valor and left, barely making it back to base."
                if b=29 then
                    'Merchant captain selling data
                    c=rnd_range(0,3)
                    d=c+1
                    if d>3 then d=1
                    if d<c then swap d,c
                    ba(0)=10
                    for e=10 to lastwaypoint
                        if targetlist(e).x=basis(0).c.x and targetlist(e).y=basis(0).c.y then ba(1)=e 
                        if targetlist(e).x=basis(1).c.x and targetlist(e).y=basis(1).c.y then ba(2)=e 
                        if targetlist(e).x=basis(2).c.x and targetlist(e).y=basis(2).c.y then ba(3)=e 
                    next
                    pr=abs(ba(d)-ba(c))
                    if c=0 then 
                        text="A merchant captain offers to sell sensor data from his trip form earth to station 1 for " &pr &" Credits."
                    else
                        text="A merchant captain offers to sell sensor data from his trip form station "&c &" to station "&d &" for " &pr &" Credits."
                    endif
                    ba(0)=10
                    if askyn(text &"(y/n)") then
                        if paystuff(pr) then
                            dprint "The merchant captain hands you a data crystal."
                            for e=ba(c) to ba(d)
                                for x=targetlist(e).x-1 to targetlist(e).x+1
                                    for y=targetlist(e).y-1 to targetlist(e).y+1
                                        if x>=0 and y>=0 and x<=sm_x and y<=sm_y then
                                            if spacemap(x,y)=0 then
                                                spacemap(x,y)=1
                                            else
                                                spacemap(x,y)=abs(spacemap(x,y))
                                            endif
                                            for f=0 to laststar
                                                if map(f).c.x=x and map(f).c.y=y then map(f).discovered=1
                                            next
                                        endif
                                    next
                                next
                            next
                        endif
                    endif
                endif
                if b=30 then
                    c=sysfrommap(specialplanet(13))
                    dprint "A frequent patron tells you that Murchesons ditch is at coordinates "&cords(map(c).c)&"."
                endif
                if b=31 then
                    c=sysfrommap(specialplanet(10))
                    dprint "A scout pilot tells you that there is an independent colony at coordinates "&cords(map(c).c)&"."
                endif
                if b=32 then
                    c=sysfrommap(specialplanet(14))
                    dprint "A well doing merchant tells you that he bought his armed merchantman class ship in a system at coordinates "&cords(map(c).c)&"."
                endif
                if b=33 then
                    c=sysfrommap(specialplanet(2))
                    dprint "A scout pilot claims that nobody has ever returned from exploring a system at coordinates "&cords(map(c).c) &"."
                endif
                if b=34 then
                    c=sysfrommap(specialplanet(27))
                    dprint "A scout pilot claims that nobody has ever returned from exploring a system at coordinates "& cords(map(c).c) &"."
                endif
                if b=35 then
                    c=sysfrommap(specialplanet(39))
                    dprint "A merchant says he buys all his grain at coordinates "&cords(map(c).c) &"."
                endif
                if b=36 or b=37 or b=38 or b=39 then
                    dprint "A scout ship captain tells a tale about how he got chased back to his ship by hostile aliens, but then had the genius idea to order his ship by radio to fire it's ship weapons at them, with devastating results!"
                endif
                
                if b=40 or b=41 then
                    dprint "A cruiser captain recounts a battle against a pirate fleet, that was going badly, until he managed to force his opponents into his plasma stream, destroying their ships."
                endif
                
                if b=42 then dprint "Somebody tells you that the leader of the pirates is choosen in a spaceship duel."
                
                if b=43 then dprint "A scout captain insists: 'There are planets out there where the ice will come after you and kill you! I call them Icetrolls, they freeze during the night, and thaw during the day. Keep in the dark when you are on such a planet.'"
                
                if b=44 then dprint "A merchant captain proclaims: 'If you want to avoid pirate attacks, just fly a triax traders flag!' " &first_uc(randomgender) & " is pretty drunk and refuses to elaborate."
                
                if b=45 then dprint "A security member tells a sobstory about how his tribble helped him when a friend of his was killed by wildlife on some planet"
                
                if b=1001 then dprint "An explorer captain tells a funny story about a captain "& randomgender &" knew, who didn't return from an expedition to a system at "&cords(map(bonesflag).c) &"."

                if b=100 then 
                    if faction(0).war(1)>50 then
                        if askyn ("A seedy looking indivdual approaches you. 'If you are interested I could keep you informed about what the merchants are loading. What do you say? 100 Cr. each time you come here?'(y/n)") then
                            factionadd(0,1,-1)
                            basis(st).spy=1 
                            dprint "'Deal then. Of course we never had this conversation'"
                        else
                            dprint "He says: 'I must have mistaken you for someone else. I apologize' and dissapears in the crowd."
                            factionadd(0,1,1)
                        endif
                    else
                        if askyn ("A seedy looking indivdual comes up to you. 'If you are interested i could see to it that the pirates don't get information about your cargo. what do you say? 100 Cr. each time you come here?'(y/n)") then
                            factionadd(0,1,-1)
                            basis(st).spy=2 
                            dprint "'Deal then. Of course we never had this conversation'"
                        else
                            dprint "He says: 'I must have mistaken you for someone else. I apologize' and dissapears in the crowd."
                            factionadd(0,1,+1)
                        endif
                    endif
                endif
           endif
        endif
        display_ship
        drawroulettetable()
        if a>=5 and a<leave then questguy_dialog(qgindex(a))
    loop until a=leave or a=-1
    set__color(11,0)
    cls
    result =mwon-mlos
    if result>30000 then result=30000
    return mwon-mlos
end function

function play_slot_machine() as short
    dim as short bet,win,a,b,c,d,debug
    do
        set__color(11,0)
        cls
        display_ship
        dprint "How much do you want to bet(0-100)"
        if debug=0 and _debug=0 then
            bet=getnumber(0,100,0)
        else 
            bet=100
        endif
        if bet>player.money then bet=0
        if bet>0 then
            player.money=player.money-bet
            a=rnd_range(1,9)
            b=rnd_range(1,9)
            c=rnd_range(1,9)
            for d=1 to 10+rnd_range(1,6) + rnd_range(1,6)
                if rnd_range(1,100)>33 then a+=1
                if rnd_range(1,100)>33 then b+=1
                if rnd_range(1,100)>33 then c+=1
                
                if a>9 then a=1
                if b>9 then b=1
                if c>9 then c=1
                if configflag(con_tiles)=0 then
                    line (45*_fw2+1*_tix,10*_tiy)-(45*_fw2+3*_tix,11*_tiy),rgba(0,0,0,255),bf
                    
                    put (45*_fw2+1*_tix,10*_tiy),gtiles(a+68),trans
                    put (45*_fw2+2*_tix,10*_tiy),gtiles(b+68),trans
                    put (45*_fw2+3*_tix,10*_tiy),gtiles(c+68),trans
                else
                    if a<8 then
                        set__color( spectraltype(a),0)
                        draw string (45*_fw2+1*_fh1,10*_fw1),"*",,font1,custom,@_col
                    else
                        if a=8 then set__color( 7,0)
                        if a=9 then set__color( 179,0)
                        draw string (45*_fw2+1*_fh1,10*_fw1),"o",,font1,custom,@_col
                    endif
                    
                    
                    if b<8 then
                        set__color( spectraltype(b),0)
                        draw string (45*_fw2+2*_fh1,10*_fw1),"*",,font1,custom,@_col
                    else
                        if b=8 then set__color( 7,0)
                        if b=9 then set__color( 179,0)
                        draw string (45*_fw2+2*_fh1,10*_fw1),"o",,font1,custom,@_col
                    endif
                    
                    
                    if c<8 then
                        set__color( spectraltype(c),0)
                        draw string (45*_fw2+3*_fh1,10*_fw1),"*",,font1,custom,@_col
                    else
                        if c=8 then set__color( 7,0)
                        if c=9 then set__color( 179,0)
                        draw string (45*_fw2+3*_fh1,10*_fw1),"o",,font1,custom,@_col
                    endif
                    
                endif
                sleep 50+d*10
            next
            win=0
            if a=b and b=c then win=(a)*2+1
            if (a=b or b=c or a=c) and win=0 then win=1
            if (a=9 or b=9 or c=9) then win=win+1
            
            if win=0 then
                dprint "You lose "& bet &" Cr."
            else
                
                addmoney(bet*win,mt_gambling)
                dprint "You win "& bet*win &" Cr."
            endif
            if debug=0 then sleep
        endif
    loop until bet<=0
    
    return 0
end function

function add_passenger(n as string,typ as short, price as short, bonus as short, target as short, ttime as short, gender as short) as short
    dim c as short
    c=get_freecrewslot
    if c>0 then
        crew(c).n=n
        crew(c).icon="p"
        crew(c).equips=1
        crew(c).hpmax=1
        crew(c).hp=1
        crew(c).typ=typ
        crew(c).target=target
        crew(c).time=ttime
        crew(c).price=price
        crew(c).bonus=bonus
        crew(c).onship=1
        crew(c).morale=150
        crew(c).story(10)=gender
        if rnd_range(1,100)<5 then
            infect(c,rnd_range(1,12))
        endif
    else
        dprint "You don't have enough room"
    endif
    return 0
end function


function check_passenger(st as short) as short
    dim as short b,t,price
    dim as _crewmember cr
    dim as string heshe(1)
    heshe(0)="She"
    heshe(1)="He"
    for b=6 to 128
        if crew(b).target<>0 then
            if crew(b).target=st+1 then
                if crew(b).typ>30 then 
                    questguy(crew(b).typ-30).location=st
                    if questguy(crew(b).typ-30).has.type=qt_travel then questguy(crew(b).typ-30).has.given=1 
                    if questguy(crew(b).typ-30).want.type=qt_travel then questguy(crew(b).typ-30).want.given=1 
                endif
                t=crew(b).time-player.turn
                price=crew(b).price+crew(b).bonus*t
                if price<0 then price=10
                if t>0 then dprint "Your passenger is very happy that " &lcase(heshe(crew(b).story(10)))& " arrived early.",c_gre
                if t<0 then dprint "Your passenger isn't happy at all that " &lcase(heshe(crew(b).story(10)))& " arrived too late.",c_yel
                addmoney(price,mt_quest2)
                dprint heshe(crew(b).story(10)) &" pays you "&credits(price) &" Cr.",c_gre
                crew(b)=cr
            else
                crew(b).morale-=10
                t=crew(b).time-player.turn
                if t<0 then crew(b).morale+=t
                if rnd_range(1,100)<10 then
                    if t<0 then dprint crew(b).n &" reminds you that " &lcase(heshe(crew(b).story(10)))& " should have been at station "&crew(b).target & " by turn "&crew(b).time &"."
                    if t>0 then dprint crew(b).n &" reminds you that " &lcase(heshe(crew(b).story(10)))& " should be at station "&crew(b).target & " by turn "&crew(b).time &"."
                endif
            endif
        endif
    next
    return 0
end function

function count_gas_giants_area(c as _cords,r as short) as short
    dim as short cc,i,j
    for i=0 to laststar
        if distance(c,map(i).c)<r then
            for j=1 to 9
                if isgasgiant(map(i).planets(j)) then cc+=1
                if map(i).planets(j)=specialplanet(21) then cc+=5
                if map(i).planets(j)=specialplanet(22) then cc+=5
                if map(i).planets(j)=specialplanet(23) then cc+=5
                if map(i).planets(j)=specialplanet(24) then cc+=5
                if map(i).planets(j)=specialplanet(25) then cc+=5
            next
        endif
    next
    
    return cc
end function



function refuel(st as short,price as single) as short
    dim as single refueled,b,totammo
    player.fuel=fix(Player.fuel)
    refueled=player.fuelmax+player.fuelpod-player.fuel
    if refueled>0 and player.money>0 then
        if cint(refueled*price)>player.money then refueled=fix(player.money/price)
        player.money-=cint(refueled*price)
        player.fuel+=cint(refueled)
        dprint "Your fill your tanks."
    else
        if refueled=0 then
            dprint "Your tanks are full."
        else
            dprint "You have no money."
        endif
    endif
    totammo=missing_ammo
    if totammo*((player.loadout+1)^2)>player.money then totammo=player.money/((player.loadout+1)^2)
    if totammo>0 and player.money>0 then
        player.money=player.money-totammo*((player.loadout+1)^2)
        do
            for b=1 to 10
                if player.weapons(b).ammo<player.weapons(b).ammomax and totammo>0 then
                    player.weapons(b).ammo+=1
                    totammo-=1
                endif
            next
        loop until totammo=0
        dprint "You reload ammunition."
    else
        if totammo=0 then
            dprint "Your ammo bins are full."
        else
            dprint "You have no money."
        endif
    endif
    return 0
end function

function max_hull(s as _ship) as short
    dim as short a,r
    for a=1 to 5
        if s.weapons(a).made=87 then r+=5
    next
    r+=s.h_maxhull
    r=r*(1+((s.armortype-1)/5))
    return r
end function

function repair_hull(pricemod as single=1) as short
    dim as short a,b,c,d,add
    
    display_ship
    if player.hull<max_hull(player) then
        dprint "you can add up to " & max_hull(player)-player.hull &" Hull points (" & credits(fix(pricemod*100*(0.5+0.5*player.armortype))) & " Cr. per point, max " &minimum(max_hull(player)-player.hull,int(player.money/100)) &")"
        b=getnumber(0,max_hull(player)-player.hull,player.hull)
        if b>0 then
            if b+player.hull>max_hull(player) then b=max_hull(player)-player.hull
            if paystuff(b*pricemod*100*(0.5+0.5*player.armortype)) then player.hull=player.hull+b
        endif
    else
        dprint "your ship is fully armored"
    endif

    return 0
end function

function sick_bay(st as short=0,obe as short=0) as short
    dim text as string
    dim lastaug as byte
    dim augn(20) as string
    dim augp(20) as short
    dim augd(20) as string
    dim augf(20) as byte
    dim augv(20) as byte
    dim n as string
    '"Augments/ Targeting - 100 Cr/ Muscle Enhancement - 100 Cr/ Infrared Vision - 100 Cr/ Speed Enhancement - 100 Cr/ Exosceleton - 100 Cr/ Damage resistance - 100Cr/Exit")
                
    augn(1)="Targeting"
    augp(1)=100-st*20
    augd(1)="A targeting computer linked directly to the brain"
    augf(1)=1
    augv(1)=1
    
    augn(2)="Muscle Enhancement"
    augp(2)=100-st*20
    augf(2)=2
    augv(2)=1
    augd(2)="Artificial glands producing adrenalin on demand, increasing strength."
    
    augn(3)="Improved lungs"
    augp(3)=80-st*20
    augf(3)=3
    augv(3)=1
    augd(3)="User has lower oxygen requirement." 
    
    augn(4)="Speed Enhancement"
    augp(4)=150-st*20
    augd(4)="Artificial muscular tissue, increasing running speed"
    augf(4)=4
    augv(4)=1
    
    augn(5)="Exoskeleton"
    augp(5)=100-st*20
    augd(5)="An artificial exoskeleton to prevent damage."
    augf(5)=5
    augv(5)=1
    
    augn(6)="Metabolism Enhancement"
    augp(6)=150-st*20
    augd(6)="Increased pain threshholds and higher hormone output enable to withstand wounds longer."
    augf(6)=6
    augv(6)=1
    
    augn(7)="Floatation Legs"
    augp(7)=50-st*20
    augd(7)="Allowes walking on water"
    augf(7)=7
    augv(7)=1
    
    augn(8)="Built in Jetpack"
    augp(8)=200-st*20
    augd(8)="Allowes the user to fly similiar like when using a jetpack"
    augf(8)=8
    augv(8)=1
    
    augn(9)="Chameleon Skin"
    augp(9)=100-st*20
    augd(9)="Not so much like a skin, this installs a field bending light around the wearer, rendering him invisible."
    augf(9)=9
    augv(9)=1
    
    augn(10)="Neural Computer"
    augp(10)=100-st*20
    augd(10)="Increases the users learning ability."
    augf(10)=10
    augv(10)=1
    
    augn(11)="Targeting II"
    augp(11)=300-st*20
    augd(11)="A targeting computer linked directly to the brain"
    augf(11)=1
    augv(11)=2
    
    augn(12)="Muscle Enhancement II"
    augp(12)=300-st*20
    augf(12)=2
    augv(12)=2
    augd(12)="Artificial glands producing adrenalin on demand, increasing strength."

    augn(13)="Exoskeleton II"
    augp(13)=300-st*20
    augd(13)="An artificial exoskeleton to prevent damage."
    augf(13)=5
    augv(13)=2
    
    augn(14)="Metabolism Enhancement II"
    augp(14)=450-st*20
    augd(14)="Increased pain threshholds and higher hormone output enable to withstand wounds longer."
    augf(14)=6
    augv(14)=2    
    
    if st=1 then
        n="Surgeries - no questions asked"
        lastaug=20
        
        augn(15)="Targeting III"
        augp(15)=500-st*20
        augd(15)="A targeting computer linked directly to the brain. This level of augmentation is usually reserved for the Military and megacorps."
        augf(15)=1
        augv(15)=3
        
        augn(16)="Muscle Enhancement III"
        augp(16)=500-st*20
        augf(16)=2
        augv(16)=3
        augd(16)="Artificial glands producing adrenalin on demand, increasing strength. This level of augmentation is usually reserved for the Military and megacorps"
    
        augn(17)="Exoskeleton III"
        augp(17)=500-st*20
        augd(17)="An artificial exoskeleton to prevent damage. This level of augmentation is usually reserved for the Military and megacorps"
        augf(17)=5
        augv(17)=3
        
        augn(18)="Metabolism Enhancement III"
        augp(18)=750-st*20
        augd(18)="Increased pain threshholds and higher hormone output enable to withstand wounds longer. This level of augmentation is usually reserved for the Military and megacorps"
        augf(18)=6
        augv(18)=3
        
        augn(19)="Loyalty chip"
        augp(19)=200
        augd(19)="Instills respect and loyalty, making it impossible to retire. There are rumors that these are used in some elite military squads, but in most places they are illegal."
        augf(19)=11
        augv(19)=1
    
        augn(20)="Synthetic Nerves"
        augp(20)=300
        augd(20)="Replaces the recipients nerve system, making it easer to control augmentations (And survive the process of adding them)."
        augf(20)=12
        augv(20)=1
    
    else
        if obe=4 then
            n="OBE Research Lab"
            lastaug=14
        else
            n="Sickbay"
            lastaug=8
        endif
    endif
    
    dim as short a,b,c,price,cured,c2
    for a=1 to lastaug
        augn(0)=augn(0)&augn(a)&space(_swidth-len(augn(a))-len(credits(augp(a))))  &credits(augp(a))&" Cr. /"
        augd(0)=augd(0)&augd(a)&"/"
    next
    do
        set__color(11,0)
        cls
        display_ship()
        dprint ""
        a=menu(bg_parent,n &"/ Buy supplies / Treat crewmembers/ Buy crew augments/Exit")
        if a=1 then
            shop(21+st,1,"Medical Supplies")
        endif
        if a=2 then
            'if player.disease>0 then price=price+10*player.disease
            price=0
            for b=1 to 128
                if crew(b).disease>0 and crew(b).hp>0 and crew(b).hpmax>0 then
                    price=price+5*crew(b).disease-st*3
                endif
            next
            if player.disease>0 then price=price+5*player.disease
            if price>0 then
                if askyn("Treatment will cost "&price &" Cr. Do you want the treatment to begin?") then
                    if paystuff(price) then
                        for b=0 to 128
                            if crew(b).disease>0 and crew(b).hp>0 and crew(b).hpmax>0 then
                                cured+=1
                                crew(b).disease=0
                                crew(b).onship=crew(b).oldonship
                            endif
                        next
                        dprint cured &" crewmembers were cured."
                        player.disease=0
                    endif
                endif
            else
                dprint "You have no sick crewmembers."
                player.disease=0
            endif
        endif
        if a=3 then
            do
                set__color(11,0)
                cls
                display_ship()
                dprint ""
                b=menu(bg_parent,"Augments/"&augn(0)&"Exit","/"&augd(0))
                if b>0 and b<=lastaug then
                    do
                        c=showteam(0,1,augn(b)&c)
                        if c>0 then c2=1
                        if c=-1 then
                            if crew(6).hpmax>0 then
                                c=6
                            else
                                c=1
                            endif
                            c2=0
                        endif
                        screenset 0,1
                        set__color(11,0)
                        cls
                        display_ship()
                        flip
                        screenset 1,1
                        if c<>0 then
                            do
                                if c=1 and b=19 then 'No Loyalty Chip for Captain 
                                    if c2=0 then 
                                        c=2
                                    else
                                        c=0
                                    endif
                                endif
                                if (crew(c).typ<=9 or crew(c).typ>=14) and b>0 and c>0 then
                                    if crew(c).augment(augf(b))<augv(b) then
                                        if player.money>=augp(b) and crew(c).hp>0 then
                                            if crew(c).augment(0)<=2 or st<>0 then
                                                if st<>0 and crew(c).augment(0)>2 then 
                                                    if not(askyn("Installing more than 3 augmentations can be dangerous, even kill the recipient. shall we proceed? (y/n)")) then c=-1
                                                endif        
                                                if c>=0 then
                                                    if crew(c).augment(augf(b))=0 then crew(c).augment(0)+=1
                                                    player.money=player.money-augp(b)
                                                    if augf(b)=6 then 
                                                        crew(c).hp=crew(c).hp+augv(b)-crew(c).augment(augf(b))
                                                        crew(c).hpmax=crew(c).hpmax+augv(b)-crew(c).augment(augf(b))
                                                    endif
                                                    crew(c).augment(augf(b))=augv(b)
                                                    dprint augn(b) & " installed in "&crew(c).n &"."
                                                    if crew(c).augment(0)>3 and rnd_range(1,6) +rnd_range(1,6)-crew(c).augment(12)*2>11-crew(c).augment(0) then
                                                        if rnd_range(1,100)<33-crew(c).augment(12)*15 then
                                                            crew(c).hp=0
                                                        else
                                                            crew(c).hpmax-=rnd_range(1,3-crew(c).augment(12)*2)
                                                            if crew(c).hp>crew(c).hpmax then crew(c).hp=crew(c).hpmax
                                                        endif
                                                        if crew(c).hp<=0 then
                                                            dprint crew(c).n &" has died during the operation."
                                                        else
                                                            dprint crew(c).n &" was permanently injured during the operation."
                                                        endif
                                                        no_key=keyin
                                                        if c=1 then player.dead=28
                                                    endif
                                                endif
                                            else
                                                dprint "We can't install more than 3 augmentations."
                                                no_key=keyin
                                            endif
                                        else
                                            if crew(c).hp>0 then 
                                                dprint "You don't have enough money.",14
                                                no_key=keyin
                                            else 
                                                dprint crew(c).n &" is dead."
                                                no_key=keyin
                                            endif
                                        endif
                                    else
                                        dprint crew(c).n &" already has "&augn(b)&"."
                                        no_key=keyin
                                    endif
                                else
                                    dprint "We can only install augments in humans."
                                    no_key=keyin
                                endif
                                c+=1
                            loop until crew(c).hpmax<=0 or c2>0 or player.money<augp(b)
                        endif
                    loop until c=0
                endif
            loop until b=lastaug+1 or b=-1 or player.dead<>0
        endif
    loop until a=4
    return player.disease
end function

function used_ships() as short
    dim as short yourshipprice,i,a,yourshiphull,price(8),l
    dim s as _ship
    dim as single pmod
    dim as string mtext,htext,desig(8)
    do
        yourshiphull=player.h_no
        s=gethullspecs(yourshiphull,"data/ships.csv")
        yourshipprice=s.h_price*.1
        mtext="Used ships (" &credits(yourshipprice)& " Cr. for your ship.)/"
        htext="/"
        for i=1 to 8
            pmod=(80-usedship(i).y*3)/100
            s=gethullspecs(usedship(i).x,"data/ships.csv")
            l=len(trim(s.h_desig))+len(credits(s.h_price*pmod))
            mtext=mtext &s.h_desig &space(45-l)&credits(s.h_price*pmod) &" Cr./"
            price(i)=s.h_price*pmod-yourshipprice
            desig(i)=s.h_desig
            htext=htext &makehullbox(s.h_no,"data/ships.csv") &"/"
        next
        mtext=mtext & "Exit"
        a=menu(bg_ship,mtext,htext,2,2)
        if a>=1 and a<=8 then
            if buy_ship(a,desig(a),price(a)) then
                usedship(a).x=yourshiphull
                player.cursed=usedship(a).y
                usedship(a).y=0
            endif
        endif
    loop until a=9 or a=-1        
    return 0
end function


function shipyard(where as byte) as short
    dim as short a,b,c,d,e,last,designshop,ex,armor,shipstart,shipstop,shipstep,inspection
    dim as string men,des
    dim s as _ship
    dim pr(20) as integer
    dim ds(20) as string
    dim st(20) as short
    men=shipyardname(where)&"/"
    des="/"
    a=1
    select case where
    case sy_military
        shipstart=2
        shipstop=12
        shipstep=2
    case sy_civil
        shipstart=1
        shipstop=11
        shipstep=2
    case sy_pirates
        shipstart=2
        shipstop=16
        shipstep=2
    case sy_blackmarket
        shipstart=12
        shipstop=16
        shipstep=1
    end select
    
    for b=shipstart to shipstop step shipstep
        s=gethullspecs(b,"data/ships.csv")
        st(a)=b
        pr(a)=s.h_price*haggle_("down")
        ds(a)=s.h_desig
        men=men & s.h_desig & space(_swidth-len(trim(s.h_desig))-len(credits(pr(a)))) &credits(pr(a)) &" Cr./"
        des=des &makehullbox(b,"data/ships.csv") &"/"
        a+=1
        last=last+1
    next
    
    men=men &"General overhaul"&space(_swidth-16-len(credits(player.h_price*.05))) & credits(player.h_price*.05) &" Cr./"
    des=des &"A thorough inspection, looking for any possible source of technical problems./"
    inspection=last+1
    last+=1
    if where=sy_pirates then 'Pirateplanet has no shipshop
        armor=last+1
        ex=last+2
    else
        men=men & "Design Hull/"
        des=des &"/"
        designshop=last+1
        armor=last+2
        ex=last+3
    endif
    
    men=men &"Change Armortype/"
    des=des &"Strip the current Armor off your ship, and replace with another type/"
    men=men &"Exit"
    des=des &"/"
    do 
        c=menu(bg_shiptxt,men,des)
        if c<last then buy_ship(st(c),ds(c),pr(c))
        if c=armor then change_armor(0)
        if c=designshop then custom_ships(where)
        if c=inspection then ship_inspection(player.h_price*0.05)
    loop until c=ex or c=-1
    set__color(11,0)
    cls
    return 0
end function

function ship_inspection(price as short) as short
    if paystuff(price) then
        if rnd_range(1,6) +rnd_range(1,6)>10-player.cursed then 'Heavily cursed stuff is easier to find. It gets harder to find the little stuff
            if player.cursed=0 then
                dprint "Your ship is in excellent shape.",c_gre
            else
                player.cursed-=1
                dprint "The inspection does reveal some minor flaws. Luckily they are quickly fixed.",c_yel
            endif
        else
            dprint "Your ship is in excellent shape.",c_gre
        endif
    endif
    return 0
end function


function buy_ship(st as short,ds as string,pr as short) as short
    
    if paystuff(pr) then
        if st<>player.h_no then
            if upgradehull(st,player)=-1 then
                dprint "you buy "&add_a_or_an(ds,0)&" hull"
                return -1
            else
                player.money=player.money+pr'Just returning the money
            endif             
        else
            dprint "You already have that hull."
            player.money=player.money+pr'Just returning the money
        endif
    endif
    return 0
end function

function missing_ammo() as short
    dim as short a,r
    for a=1 to 9
        if player.weapons(a).ammomax>0 and player.weapons(a).ammo<player.weapons(a).ammomax then
            r=r+player.weapons(a).ammomax-player.weapons(a).ammo
        endif
    next
    return r
end function


function change_loadout() as short
    dim as short ammo,i,ex,a
    dim as string text,help
    
    text="Ammunitions/"&ammotypename(0)&"   1 Cr./"&ammotypename(1)&"      4 Cr./"&ammotypename(2)&"      9 Cr./"&ammotypename(3)&"      16 Cr."
    help="/A dumb shell, no explosives, no propulsion. Damage is mainly done through impact. || Dam: 1 | Price: 1 Cr"
    help=help &"/Like the dumb shell, but with additional explosives|| Dam: 2 | Price: 4 Cr."
    help=help &"/A small nuclear warhead for space combat || Dam: 3 | Price: 9 Cr."
    help=help &"/A fusion bomb for space combat || Dam: 4 | Price: 16 Cr"
    if artflag(22)=2 then
        text=text &"/"&ammotypename(4)&"     25 Cr."
        help=help &"/Based on alien technology, this warhead seems to detonate space itself. || Dam: 5 | Price: 25 Cr"
        ex=6
    else
        ex=5
    endif
    text=text &"/Exit"
    
    a=menu(bg_ship,text,help)
    if a>0 and a<ex then
        if a=player.loadout+1 then
            dprint "You already have that loadout"
        else
            player.loadout=a-1
            for i=1 to 9
                if player.weapons(i).ammo>0 then player.weapons(i).ammo=0
            next
            dprint "Your loadout is now "&ammotypename(player.loadout) &"."
        endif
    endif
    
    return 0
end function

    
function change_armor(st as short) as short
    dim as short a,i,price(5),e
    dim as string text,help
    for i=1 to 5
        price(i)=player.hull*i+max_hull(player)*(0.5+0.5*i)
    next
    if artflag(21)=2 then
        e=6
    else
        e=5
    endif
    text="Armor/"
    text=text &"Standard (" & price(1) & "Cr.)/"
    text=text &"Laminate (" & price(2) & "Cr.)/"
    text=text &"Nanocomposite (" & price(3) & "Cr.)/"
    text=text &"Diamonoid (" & price(4) & "Cr.)/"
    if artflag(21)=2 then text=text &"Neutron (" & price(5) & "Cr.)/"
    text=text &"Exit"
    help=help &"/Standard armor alloy.| "&player.h_maxhull*1 &" max armor, at " &player.h_maxhull*1^2 &" cost /"
    help=help &"Standard armor alloy, reinforced with carbon fibers.| "&player.h_maxhull*1.5 &" max armor, at "& player.h_maxhull*1.5^2 &" cost /"
    help=help &"Polymers, reinforced with carbon nanotubes.| "&player.h_maxhull*2 &" max armor, at "& player.h_maxhull*2^2 &" cost /"
    help=help &"Carbon arranged in a diamond like structure.| "&player.h_maxhull*2.5 &" max armor, at "& player.h_maxhull*2.5^2 &" cost /"
    if artflag(21)=2 then help=help &"Armor made out of pure neutronium.| "&player.h_maxhull*3 &" max armor, at "& player.h_maxhull*3^2 &" cost /"
    a=menu(bg_ship,text,help)
    if a>0 and a<e then
        if a=player.armortype then
            dprint "You already have that armortype"
        else
            if paystuff(price(a)) then player.armortype=a
        endif
    endif
        
    return 0
end function


function ship_design(where as byte) as short
    dim as short ptval,pts,a,b,cur,f,maxweapon,st,ex
    dim as string component(10),key
    dim price(10) as short
    dim value(10) as short
    dim incr(10) as short
    dim h as _ship
    if count_lines("data/customs.csv")>20 then 
        dprint "Too many designs in custom.csv. You need to delete one before you can add new ones"
        return 0
    endif
    
    component(1)="Hull "
    price(1)=150
    incr(1)=1
    component(2)="Shield "
    price(2)=100
    incr(2)=1
    component(3)="Engine "
    price(3)=50
    incr(3)=1
    component(4)="Sensors "
    price(4)=50
    incr(4)=1
    component(5)="Cargo "
    price(5)=200
    incr(5)=1
    component(6)="Crew "
    value(6)=5
    price(6)=100
    incr(6)=1
    component(7)="Weaponslots "
    price(7)=300
    incr(7)=1
    component(8)="Fuel "
    price(8)=10
    incr(8)=5
    if where=sy_blackmarket then
        a=menu(bg_awayteam,"Choose shiptype/Small Ship/Medium Ship/Big Ship/Huge Ship/Exit")
        ex=5
    else
        a=menu(bg_ship,"Choose shiptype/Small Ship/Medium Ship/Exit")
        ex=3
    endif
    if a>0 and a<ex then
        maxweapon=a+2
        st=a
        if a=1 then ptval=300
        if a=2 then ptval=450
        if a=3 then ptval=600
        if a=4 then ptval=750
        pts=ptval
        a=1
        do
            price(0)=0
            for a=1 to 8
                price(0)+=price(a)*value(a)
                if cur=a then
                    set__color( 15,5)
                else
                    set__color( 11,0)
                endif
                draw string(2*_FW2,(3+a)*_FH2),space(25),,FONT2,Custom,@_col
                draw string (3*_FW2,(3+a)*_FH2),component(a)&"("&value(a)&"):"&price(a) &"Cr.",,FONT2,CUSTOM,@_COL
            next
            set__color( 15,0)
            draw string(2*_FW2,2*_FH2),space(25),,FONT2,Custom,@_col
            draw string(2*_FW2,3*_FH2),space(25),,FONT2,Custom,@_col
            draw string(2*_FW2,3*_FH2),"Points("&ptval &"): "&pts,,FONT2,Custom,@_col
            draw string(2*_FW2,12*_FH2),space(25),,FONT2,Custom,@_col
            draw string(2*_FW2,13*_FH2),space(25),,FONT2,Custom,@_col
            draw string(2*_FW2,12*_FH2),"Price: "&price(0),,FONT2,Custom,@_col
            if cur=a then
                set__color( 15,5)
            else
                set__color( 11,0)
            endif
            draw string(2*_FW2,13*_FH2),space(25),,FONT2,Custom,@_col
            draw string(2*_FW2,13*_FH2),"Exit",,FONT2,Custom,@_col
            
            key=keyin(key_north &key_south &"+-"&key_west &key_east)
            if key=key_north then cur=cur-1
            if key=key_south then cur=cur+1
            if cur<1 then cur=9
            if cur>9 then cur=1
            if cur<9 then
                
                if key=key_east or key="+" then 
                    if (cur<>7 or value(cur)<maxweapon) or (cur=5 and value(cur)<11) then
                        if pts>=price(cur)*incr(cur)/10 then
                            pts=pts-price(cur)*incr(cur)/10
                            value(cur)+=incr(cur)
                        endif
                    endif
                endif
                if key=key_west or key="-" then 
                    if (cur<>6 and value(cur)>0) or (cur=6 and value(cur)>5) then
                        pts=pts+price(cur)*incr(cur)/10
                        value(cur)-=incr(cur)
                    endif
                endif
            endif
        loop until ptval=0 or key=key__esc or (cur=9 and key=key__enter)
        if askyn("Do you want to keep this ship design?(y/n)") then
            h.h_maxhull=value(1)
            h.h_maxengine=value(3)
            h.h_maxshield=value(2)
            h.h_maxsensors=value(4)
            h.h_maxcargo=value(5)
            h.h_maxcrew=value(6)
            h.h_maxweaponslot=value(7)
            h.h_maxfuel=value(8)
            h.h_price=price(0)
            h.h_desc=""&st
            draw string(2*_FW2,12*_FH2),"Design Name: ",,FONT2,Custom,@_col
            draw string(2*_FW2,13*_FH2),space(25),,FONT2,Custom,@_col
            h.h_desig =gettext(2,13,24,"")
            draw string(2*_FW2,12*_FH2),"Design Short:",,FONT2,Custom,@_col
            draw string(2*_FW2,13*_FH2),space(25),,FONT2,Custom,@_col
            h.h_sdesc =gettext(2,13,4,"")
            f=freefile
            open "data/customs.csv" for append as #f
            print #f,h.h_desig &";"& h.h_price &";"& h.h_maxhull &";"& h.h_maxshield &";"& h.h_maxengine &";"& h.h_maxsensors &";"& h.h_maxcargo &";"& h.h_maxcrew &";"& h.h_maxweaponslot &";"& h.h_maxfuel &";"& h.h_sdesc &";10;" & h.h_desc
            close #f
            dprint "Ship design saved"
        endif
    endif
    set__color(11,0)
    cls
    return 0
end function

function custom_ships(where as byte) as short
    dim as string men,des,dummy
    dim as short i,c,ex,f,nos,a,last,v
    dim pr(20) as ushort
    dim ds(20) as string
    dim st(20) as short
    dim as _ship s
    do
        nos=count_lines("data/customs.csv")-1
        men="Custom hulls/Build custom hull/Delete custom hull/"
        des="Nil///"
        a=3
        last=3
        if nos>0 then
            for i=1 to nos
                s=gethullspecs(i,"data/customs.csv")
                v=val(s.h_desc)
                if where=sy_blackmarket or v<3 then
                    s.h_desc=s.h_desig
                    st(a)=a+20
                    pr(a)=s.h_price
                    ds(a)=s.h_desig
                    a+=1
                    men=men & s.h_desig & " - " &s.h_price  &"Cr./"
                    des=des &makehullbox(i,"data/customs.csv") &"/"
                    last=last+1
                endif
            next
        endif
        men=men &"Exit"
        c=menu(bg_parent,men,des)
        if c=1 then ship_design(where)
        if c=2 then delete_custom(where)
        if c>2 and c<last then
            if paystuff(pr(c)) then
                if st(c)<>player.h_no then
                    if upgradehull(st(c),player)=-1 then
                        dprint "you buy "&add_a_or_an(ds(c),0)&" hull"
                    else
                        player.money=player.money+pr(c)
                    endif             
                else
                    dprint "You already have that hull."
                    player.money=player.money+pr(c)
                endif
            endif
            display_ship
        endif

    loop until c=-1 or c=last
    return 0
end function

function shipupgrades(st as short) as short
    dim as short b,c,d,e,i
    dim mtext as string
    dim help as string
'    shopitem(1,20).desig="sensors MK I"
'    shopitem(1,20).price=200
'    shopitem(1,20).v1=1
'    shopitem(1,20).ty=50
'    shopitem(1,20).ldesc="Basic ship sensor set. 1 Parsec Range" 
'    
'    shopitem(2,20).desig="sensors MK II"
'    shopitem(2,20).price=800
'    shopitem(2,20).v1=2
'    shopitem(2,20).v4=1
'    shopitem(2,20).ty=50
'    shopitem(2,20).ldesc="Basic ship sensor set. 2 Parsec Range" 
'    
'    shopitem(3,20).desig="Sensors MK III"
'    shopitem(3,20).price=1600
'    shopitem(3,20).v1=3
'    shopitem(3,20).ty=50
'    shopitem(3,20).ldesc="Ship sensor set. 3 Parsec Range" 
'        
'    shopitem(4,20).desig="sensors MK IV"
'    shopitem(4,20).price=3200
'    shopitem(4,20).v1=4
'    shopitem(4,20).ty=50
'    shopitem(4,20).ldesc="Advanced ship sensor set. 4 Parsec Range" 
'    
'    shopitem(5,20).desig="sensors MK V"
'    shopitem(5,20).price=6400                        
'    shopitem(5,20).ty=50
'    shopitem(5,20).v1=5
'    shopitem(5,20).ldesc="Advanced ship sensor set. 5 Parsec Range" 
'    

    help=help &"Change type of ammo used for missile weapons."
    do 
        c=menu(bg_parent,"Ship Upgrades:/Sensors,Shields & Engines/Weapons & Modules/Change Loadout/Change Armortype/Exit")
'            mtext="Sensors/" 
'            for i=1 to 15
'                mtext=mtext &shopitem(i,20).desig &space(_swidth-len(trim(shopitem(i,20).desig))-len(credits(shopitem(i,20).price))) &credits(shopitem(i,20).price) &" Cr./"
'            next
'            mtext=mtext &"Exit"
'            do
'            d=menu(bg_parent,mtext,help)
'                    
'            display_ship
'            if d<>-1 then
'                if d>0 and d<13 then
'                    if player.money>=shopitem(d,20).price then
'                        if shopitem(d,20).ty=50 then
'                            if shopitem(d,20).v1>player.h_maxsensors then dprint "Your ship is too small for those."
'                            if shopitem(d,20).v1<player.sensors then dprint "You already have better sensors."
'                            if shopitem(d,20).v1=player.sensors then dprint "That is the same as your current sensor system."
'                            if shopitem(d,20).v1>player.sensors and shopitem(d,20).v1<=player.h_maxsensors then
'                                player.sensors=shopitem(d,20).v1
'                                paystuff(shopitem(d,20).price)
'                                dprint "You buy "&shopitem(d,20).desig &"."
'                            endif
'                        endif
'                        if shopitem(d,20).ty>50 and shopitem(d,20).ty<53 then
'                            if findbest(shopitem(d,20).ty,-1)<0 then
'                                placeitem(shopitem(d,20),0,0,0,0,-1)
'                                paystuff(shopitem(d,20).price)
'                                dprint "You buy "&shopitem(d,20).desig &"."
'                            else
'                                if item(findbest(shopitem(d,20).ty,-1)).v1<shopitem(d,20).v1 then
'                                    dprint "You already have a better "&shopitem(d,20).desig &"."
'                                else
'                                    dprint "You already have "&add_a_or_an(shopitem(d,20).desig,0) &"."
'                                endif
'                            endif
'                        endif
'                        if shopitem(d,20).ty=53 then
'                            if shopitem(d,20).v1<player.ecm then dprint "you already have a better ECM system."
'                            if shopitem(d,20).v1=player.ecm then dprint "That is the same as your current ECM system."
'                            if shopitem(d,20).v1>player.ecm then 
'                                player.ecm=shopitem(d,20).v1
'                                paystuff(shopitem(d,20).price)
'                                dprint "You buy "&shopitem(d,20).desig &"."
'                            endif
'                        endif
'                        if shopitem(d,20).ty=54 then
'                            if shopitem(d,20).v1<player.shieldedcargo then dprint "you already have a better cargo shielding."
'                            if shopitem(d,20).v1=player.shieldedcargo then dprint "That is the same as your current cargo shielding."
'                            if shopitem(d,20).v1>player.shieldedcargo then 
'                                player.shieldedcargo=shopitem(d,20).v1
'                                paystuff(shopitem(d,20).price)
'                                dprint "You buy "&shopitem(d,20).desig &"."
'                            endif
'                        endif
'                    else
'                        dprint "You don't have enough money."
'                    endif
'                endif
'            endif
'            display_ship()
'            loop until d=-1 or d=16
'            for b=0 to lastitem
'                if item(b).ty=50 then
'                    item(b)=item(lastitem)
'                    lastitem=lastitem-1
'                endif
'            next
'            display_ship()
'        endif
'            
'            if c=2 then 'Shields
'                do
'                    d=menu(bg_parent,"Shields:/ Shields MKI   -  300 Cr/ Shields MKII  - 1200 Cr/ Shields MKIII - 2700 Cr/ Shields MKIV  - 4800 Cr/ Shields MKV   - 7500 Cr/ Exit")
'                    if d<6 and d<=player.h_maxshield then
'                        if d<player.shieldmax then dprint "you already have better shields"
'                        if d=player.shieldmax then dprint "You already have this shieldgenerator"
'                        if d>player.shieldmax and d<6 then
'                            if paystuff(d*d*300) then
'                                player.shieldmax=d
'                                dprint "You upgrade your shields"
'                                d=6
'                            endif
'                        endif
'                    else
'                        if d<6 then dprint "That shieldgenerator doesnt fit in your hull"
'                    endif
'                    display_ship()
'                loop until d=6
'                
'            endif
'                   
            if c=1 then shop(20,1,"Sensors, Shields & Engines")
            if c=2 then buy_weapon(st)
            if c=3 then change_loadout
            if c=4 then change_armor(0)
            display_ship()
        loop until c=5 or c=-1
    return 0
end function

function buy_engine() as short
    dim as string metxt,hetxt
    dim as string iname(10),ihelp(10)
    dim as short iprice(10),d,i
    iname(1)="Engine MKI"
    iprice(1)=300
    iname(2)="Engine MKII"
    iprice(2)=1200
    iname(3)="Engine MKIII"
    iprice(3)=2700
    iname(4)="Engine MKIV"
    iprice(4)=4800
    iname(5)="Engine MKV" 
    iprice(5)=7500
    iname(6)="AT Landing Gear"
    iprice(6)=250
    iname(7)="Imp. AT Landing Gear"
    iprice(7)=500
    iname(8)="Maneuverjets MKI"
    iprice(8)=250
    iname(9)="Maneuverjets MKII"
    iprice(9)=500
    iname(10)="Maneuverjets MKIII"
    iprice(10)=1000
    metxt="Engine:"
    for i=1 to 10
        iprice(i)=iprice(i)*haggle_("down")
        metxt &="/"&iname(i) &space(_swidth-len(iname(i))-len(credits(iprice(i)))) &credits(iprice(i)) &" Cr."
    next
    metxt &="/Exit"
    do
        hetxt="/"
        for i=1 to 5
            hetxt=hetxt &iname(i) &"||"
            if i<player.engine then hetxt=hetxt &"You already have a better engine now"
            if i=player.engine then hetxt=hetxt &"This is the same engine as you have now."
            if i>player.engine then hetxt=hetxt &"With this engine you would have " & int(i+2-player.h_maxhull\15) & " movement points."
            if i>player.h_maxengine then hetxt &= "|This engine is too big for your ship."
            hetxt &="/"
        next
        hetxt &="special landing struts designed to make landing in all kinds of terrain easier/Special landing struts designed to make landing in all kinds of terrain easier"
        hetxt &="/Adds 1 pt to movement"
        if player.manjets=1 then hetxt &="|You already have these maneuvering jets"
        hetxt &="/Add 2 pts to movement"
        if player.manjets=2 then hetxt &="|You already have these maneuvering jets"
        hetxt &="/Adds 3 pts to movement"
        if player.manjets=3 then hetxt &="|You already have these maneuvering jets"
    
        d=menu(bg_parent,metxt,hetxt)
        if d<6 and d<=player.h_maxengine then
            if d<player.engine then dprint "You already have a better engine"
            if d=player.engine then dprint "You already have this engine"
            if d>player.engine and d<6 then
                if paystuff(iprice(d)) then
                    player.engine=d
                    dprint "You upgrade your engine"
                    display_ship()
                    d=6
                endif
            endif
        else
            if d<6 then dprint "That engine doesnt fit in your hull"
            if d=6 then 
                if paystuff(250) then
                    dprint "You buy all terrain landing gear"
                    placeitem(makeitem(75),,,,,-1)
                endif
            endif
            if d=7 then 
                if paystuff(500) then
                    dprint "You buy an improved all terrain landing gear"
                    placeitem(makeitem(76),,,,,-1)
                endif
            endif
            if d=8 then
                if paystuff(250) then
                    if player.manjets<1 then
                        dprint "You buy Maneuver Jets I"
                        player.manjets=1
                    else
                        if player.manjets>1 then dprint "you alrealdy have better maneuvering jets"
                        if player.manjets=1 then dprint "you alrealdy have these maneuvering jets"
                        player.money=player.money+250 'Just returning money
                    endif
                endif
            endif
            
            if d=9 then
                if paystuff(500) then
                    if player.manjets<2 then
                        dprint "You buy Maneuver Jets II"
                        player.manjets=2
                    else
                        if player.manjets>2 then dprint "you alrealdy have better maneuvering jets"
                        if player.manjets=2 then dprint "you alrealdy have these maneuvering jets"
                        player.money=player.money+500 'returning money
                    endif
                endif
            endif
            
            if d=10 then
                if paystuff(1000) then
                    if player.manjets<3 then
                        dprint "You buy Maneuver Jets III"
                        player.manjets=3
                    else
                        if player.manjets>3 then dprint "you alrealdy have better maneuvering jets"
                        if player.manjets=3 then dprint "you alrealdy have these maneuvering jets"
                        player.money=player.money+1000 'Returning money
                    endif
                endif
            endif
        endif
    loop until d=11
    return 0
end function

function starting_turret() as _weap
    dim as string m,help
    dim weapon(12) as _weap
    dim as short i,ws(12)
    ws(1)=1
    ws(2)=6
    ws(3)=84
    ws(4)=85
    ws(5)=87
    ws(6)=88
    ws(7)=90
    ws(8)=93
    ws(9)=96
    ws(10)=98
    ws(11)=99
    '1,6,84,85,87,88,90,93,96-99
    m="Choose turret:/"
    for i=1 to 11
        weapon(i)=makeweapon(ws(i))
        m=m &weapon(i).desig &"/"
        help=help &make_weap_helptext(weapon(i))
    next
    m=m &"Cancel"
    i=menu(bg_parent,m,help,20,2)
    if i<0 or i=12 then return weapon(0)
    return weapon(i)
end function

function buy_weapon(st as short) as short
    dim as short a,b,c,d,i,mod1,mod2,mod3,mod4,ex
    dim as short last
    dim it as _items 
    dim weapons as string
    dim key as string
    dim wmenu as string
    dim help as string
    do
        i=0
        for a=1 to 20
            if makew(a,st)<>0 then i+=1
        next
        weapons="Weapons:"
        help=""
        for a=1 to i
            b=_swidth-len(trim(wsinv(a).desig))-len(credits(wsinv(a).p*haggle_("down")))
            weapons=weapons &"/ " &trim(wsinv(a).desig) & space(b) &credits(wsinv(a).p*haggle_("down"))&" Cr."
            help=help &"/"&make_weap_helptext(wsinv(a))
        next
        
       
        
        weapons=weapons &"/Exit"
        help=help &" /"
        last=i
        ex=i+1
        
        screenset 0,1
        set__color(11,0)
        cls
        display_ship()        
        dprint ""
        d=menu(bg_parent,weapons,help,2,2)
        flip
        if d>=1 and d<=last then
            b=player.h_maxweaponslot
            wmenu="Weapon Slot/"
            for a=1 to b
                if player.weapons(a).desig="" then
                    wmenu=wmenu & "-Empty-/"
                else
                    wmenu=wmenu & player.weapons(a).desig & "/"
                endif
            next
            wmenu=wmenu+"Exit"
            b=b+1            
            c=menu(bg_parent,wmenu)
            if c<b then
                if player.weapons(c).desig<>"" and d<>5 then 
                    if not(askyn("Do you want to replace your "&player.weapons(c).desig &"(y/n)")) then c=b
                endif
                if c<b then
                    if paystuff(wsinv(d).p*haggle_("down")) then
                        if wsinv(d).made<=14 then
                            dprint "You buy "&add_a_or_an(wsinv(d).desig,0) &"."
                        else
                            dprint "You buy "&wsinv(d).desig &"."
                        endif
                        player.weapons(c)=wsinv(d)
                        for i=d to last
                            wsinv(d)=wsinv(d+1)
                            makew(d,st)=makew(d+1,st)
                        next
                        wsinv(last)=makeweapon(0)
                        makew(last,st)=0
                    endif
                endif
            endif
        endif
        
           
        recalcshipsbays
        
    loop until d=ex
                      
    return 0
end function


function pirateupgrade() as short
    dim a as short
    if player.h_maxcrew>=10 then
        player.h_maxcrew=player.h_maxcrew-5
        player.h_maxcargo=player.h_maxcargo+1
        for a=1 to 9
            if player.cargo(a).x=0 then
                player.cargo(a).x=1
                recalcshipsbays()
                return 0
            endif
        next
    endif
    recalcshipsbays()
    return 0
end function

function customize_item() as short
    dim as integer a,b,i,i2,j,price,c,nr
    dim as string t
    dim as byte debug=0
    do
        set__color(11,0)
        cls
        display_ship()
        a=menu(bg_awayteam,"Customize item/Increase accuracy/Add camo/Add imp. Camo/Acidproof/Exit")
        set__color(11,0)
        cls
        display_ship()
        if a=1 then
            i=get_item(2,4)
            if i>0 then
                dprint "Let's take a look at your "&item(i).desig &"."
                if item(i).v3<4 then
                    nr=count_items(item(i))
                    if nr>1 then 
                        dprint "How many?(1-"&nr &")"
                        nr=getnumber(0,nr,0)
                    endif
                    if debug=1 and _debug=1 then dprint ""&nr
                    price=(item(i).v3+1)*(item(i).v3+1)*100*nr*haggle_("down")
                    if askyn("That will cost "&price &" Cr.(y/n)") then
                        if paystuff(price) then 
                            for j=1 to nr
                                i=lowest_by_id(item(i).id)
                                    item(i).id+=2000
                                item(i).v3+=1
                                t=left(item(i).ldesc,instr(item(i).ldesc,"| |"))
                                for c=1 to len(item(i).ldesc)
                                    if mid(item(i).ldesc,c,1)<>"|" then
                                        t=t &mid(item(i).ldesc,c,1)
                                    else
                                        exit for
                                    endif
                                next
                                if item(i).ty=4 then item(i).ldesc=t &  "  | | Accuracy: "&item(i).v3 &" | Damage: "&item(i).v1 
                                if item(i).ty=2 then item(i).ldesc=t &  "  | | Accuracy: "&item(i).v3 &" | Damage: "&item(i).v1 &" | Range:"&item(i).v2
                            next
                        endif
                    endif
                endif
            else
                dprint "Come back when you have a weapon to modify."
            endif
        endif
        if a=2 or a=3 then
            i=get_item(3)
            if i>0 then
                dprint "Let's take a look at your "&item(i).desig &"."
                i2=lowest_by_id(item(i).id)
                if i2>0 then i=i2
                if a=2 then price=100
                if a=3 then price=250
                if item(i).v2>0 then 
                    dprint "That suit is already camoflaged."
                else
                    price=price*nr*haggle_("down")
                    if askyn("that will cost "&price &" Cr.(y/n)") then
                        if paystuff(price) then
                            if a=2 then 
                                item(i).id+=1200
                                item(i).v2=1
                                item(i).desig="Camo "&item(i).desig
                            endif
                            if a=3 then 
                                item(i).id+=1300
                                item(i).v2=3
                                item(i).desig="Imp. Camo "&item(i).desig
                            endif
                        endif
                    endif
                endif
            else
                dprint "Come back when you have a suit to modify."
            endif
        endif
        if a=4 then
            i=get_item()
            if i>0 then
                dprint "Let's take a look at your "&item(i).desig &"."
                price=50*haggle_("down")
                if askyn("That will cost " &price & " cr.(y/n)") then
                    if paystuff(price) then
                        item(i).id+=1500
                        item(i).res=120
                        item(i).desig="Acidproof "&item(i).desig
                    endif
                endif
            else
                dprint "Come back when you have something to acidproof."
            endif
        endif
    loop until a=5
    return 0
    
end function

function display_stock() as short
    dim as short a,dis(4),cn(4),last
    set__color (15,0)
    draw string(2*_fw1,2*_fh1), "Company",,font2,custom,@_col
    draw string(2*_fw1+28*_fw2,2*_fh1), "Price",,font2,custom,@_col
    set__color( 11,0)
    for a=0 to 2
        set__color( 11,0)
        if dis(basis(a).company)=0 then
            last+=1
            cn(last)=basis(a).company
            draw string(2*_fw1,2*_fh1+last*_fh2), companyname(basis(a).company),,font2,custom,@_col
            draw string(2*_fw1+28*_fw2,2*_fh1+last*_fh2), ""&companystats(basis(a).company).rate,,font2,custom,@_col
        endif
        dis(basis(a).company)=1
    next
    return last
end function


function stockmarket(st as short) as short
    dim dis(4) as byte
    dim as short a,b,c,d,amount,last
    dim cn(5) as short
    dim text as string
    text="Company" &space(18) &"Price"
    For a=0 to 2
       if dis(basis(a).company)=0 then
            b+=1
            cn(b)=basis(a).company
            dis(basis(a).company)=1 
            text=text &"/"& companyname(basis(a).company)
            text=text &space(32-len(companyname(basis(a).company))-len(credits(companystats(basis(a).company).rate)))&credits(companystats(basis(a).company).rate) &" Cr."
        endif
    next
    
    do
        last=display_stock
        portfolio(2,17)
        a=menu(bg_stock,"/Buy/Sell/Exit","",2,12)
        if a=1 then
            b=menu(bg_parent,text &"/Exit",,2,2)
            if b>0 and b<last+1 then
                if cn(b)>0 then
                    dprint "How many shares of "&companyname(cn(b))&" do you want to buy?"
                    amount=getnumber(0,99,0)
                    if amount>0 then
                        if paystuff(companystats(cn(b)).rate*amount) then
                            amount=buyshares(cn(b),amount)
                            companystats(cn(b)).capital=companystats(cn(b)).capital+amount
                        endif
                    endif
                endif
            endif
        endif
        if a=2 then
            set__color(11,0)
            cls
            display_ship
            b=getsharetype
            if b>0 then
                c=getshares(b)
                if c>99 then c=99
                dprint "How many shares of "&companyname(b)&" do you want to sell? (max "&c &")"
                    
                d=getnumber(0,c,0)
                if d>0 then
                    sellshares(b,d)
                endif
            endif
        endif
    loop until a=3
    return 0
end function

function getsharetype() as short
    dim n(4) as integer
    dim cn(4) as integer
    dim as short a,b
    dim text as string
    dim help as string
    for a=0 to lastshare
        if shares(a).company>0 and shares(a).company<=4 then
            n(shares(a).company)+=1
        endif
    next
    help="/"
    for a=1 to 4
        if n(a)>0 then
            b+=1
            cn(b)=a
            text=text &companyname(a) &" ("&n(a) &") - "&companystats(a).rate &"/"
            help=help &":"&a &":"&cn(b) &"/"
        endif
    next
    help=help & "/"
    b+=1
    if text<>"" then
        text="Company/"&text &"Exit"
        a=menu(bg_parent,text,"",2,2)
        if a>0 and a<b then 
            return cn(a)
        else
            return -1
        endif
    else
        dprint "You don't own any shares to sell"
    endif
    return -1
end function

function portfolio(x as short,y2 as short) as short
    dim n(4) as integer
    dim as short a,y
    for a=0 to lastshare
        if shares(a).company>0 and shares(a).company<=4 then
            n(shares(a).company)+=1
        endif
    next
    locate y,x
    set__color( 15,0)
    draw string(x*_fw1,y2*_fh1), "Portfolio:",,font2,custom,@_col
    set__color( 11,0)
    y=1
    for a=1 to 4
        if n(a)>0 then 
            locate y,x
            draw string(x*_fw1,y2*_fh1+y*_fh2), companyname(a) &": "& n(a),,font2,custom,@_col
            y+=1
        endif
    next
    
    return 0
end function

function dividend() as short
    dim payout(4) as single
    dim a as short
    for a=0 to lastshare
        if shares(a).company>0 and shares(a).lastpayed<=player.turn-250 then
            payout(shares(a).company)=payout(shares(a).company)+companystats(shares(a).company).rate/100
            shares(a).lastpayed=player.turn
        endif
    next
    for a=1 to 4
        payout(0)=payout(0)+payout(a)
    next
    if payout(0)>1 then
        for a=1 to 4
            if payout(a)>0 then dprint "Your share in "&companyname(a) &" has paid a dividend of "&int(payout(a)) &" Cr."
        next
        addmoney(int(payout(0)),mt_trading)
    endif
        
    return 0
end function

function cropstock() as short
    dim as short s,a
    
    for a=0 to 2
        if companystats(basis(a).company).profit>0 then
            if s=0 or companystats(basis(a).company).profit<s then s=companystats(basis(a).company).profit
        endif
    next
    s=s/2
    if s<1 then s=1
    for a=0 to 2
        if companystats(basis(a).company).profit>0 then
            companystats(basis(a).company).profit=companystats(basis(a).company).profit/s
        endif
    next
    return 0
end function

function buyshares(comp as short,n as short) as short
    dim a as short
    if companystats(comp).shares=0 then dprint "No shares availiable for this company",14
    if lastshare+n>2048 then n=2048-lastshare
    if n>0 and companystats(comp).shares>0 then
        for a=1 to n
            if lastshare<2048+n and companystats(comp).shares>0 then
                lastshare=lastshare+1
                shares(lastshare).company=comp
                shares(lastshare).bought=player.turn
                shares(lastshare).lastpayed=player.turn
                companystats(comp).shares-=1
            endif
        next
    else
        n=0
    endif
    return n
end function

function shares_value() as short
    dim as short a,v
    for a=1 to lastshare
        v+=companystats(shares(a).company).rate
    next
    return v
end function


function sellshares(comp as short,n as short) as short
    dim as short a,b,c
    for a=1 to lastshare
        if shares(a).company=comp and n>0 then
            companystats(shares(a).company).capital-=1
            addmoney(companystats(shares(a).company).rate,mt_trading)
            shares(a).company=-1
            companystats(comp).shares+=1
            n=n-1
        endif
    next
    if a>2048 then a=2048
    do
        if shares(a).company=-1 and lastshare>=0 then
            shares(a)=shares(lastshare)
            lastshare-=1
        else
            a+=1
        endif
    loop until a>lastshare or lastshare<=0
    if lastshare<0 then lastshare=0
    
    return 0
end function

function getshares(comp as short) as short
    dim as short r,a
    for a=0 to lastshare
        if shares(a).company=comp then r+=1
    next
    return r
end function


' trading
function merctrade(byref f as _fleet) as short
    dim as short st,a,debug
    debug=1
    st=-1
    for a=0 to 2
        if f.c.x=basis(a).c.x and f.c.y=basis(a).c.y then st=a
    next
    if _debug=1 then dprint "fleet at station "&st
    if st<>-1 then
        if show_NPCs then dprint "fleet is trading at "&st+1 &"."
        f=unload_f(f,st)
        f=load_f(f,st)
        f=refuel_f(f,st)
    endif
    return 0
end function

function refuel_f(f as _fleet, st as short) as _fleet
    'Refuels a fleet at a space station
    dim as short demand,ships,a,debug
    debug=1
    for a=0 to 15
        if f.mem(a).hull>0 then ships+=1
    next
    demand=cint(f.fuel*ships/30)
    basis(st).inv(9).v-=demand
    if basis(st).inv(9).v<0 then basis(st).inv(9).v=0
    if debug=1 and _debug=1 then dprint ships &" ships refueling "&demand &" fuel, on base " & basis(st).inv(9).v
    f.fuel=0
    return f
end function

function load_f(f as _fleet, st as short) as _fleet
    dim as short curship,curgood,buylevel,vol,suc,a
    dim loaded(8) as short
    dim text as string
    buylevel=11
    do
        vol=0
        for a=1 to 5
            vol=vol+basis(st).inv(a).v
        next
        if vol>0 then
            for a=1 to 8
                if basis(st).inv(a).v>buylevel and curship<16 then
                    do 
                        suc=load_s(f.mem(curship),a,st)
                        if suc=-1 then 
                            curship=curship+1
                        else
                            'save what was loaded
                            loaded(a)=loaded(a)+1
                        endif
                    loop until suc<>-1 or curship>=15
                endif
            next
        endif
        buylevel=buylevel-1
    loop until vol<5 or buylevel<3 or curship>=15
    if basis(st).spy=1 then
        for a=1 to 4
            if loaded(a)>0 then text=text & loaded(a) &" tons of "& goodsname(a)
            if loaded(a)>0 and loaded(a+1)>0 then text=text &", "
        next
        if loaded(5)>0 then text=text & loaded(a) &" tons of "& goodsname(a) &"."
        if player.landed.m=0 then dprint "We have a transmission from station "&st+1 &". A trader just left with "&text &".",15    
    endif
    
    return f
end function

function unload_f(f as _fleet, st as short) as _fleet
    dim as short a
    for a=1 to 15
        f.mem(a)=unload_s(f.mem(a),st)
    next
    return f
end function

function unload_s(s as _ship,st as short) as _ship    
    dim as short a,b,c,d,e,f,t
    
    for a=1 to 25
        if s.cargo(a).x>1 then
            if st<=2 then companystats(basis(st).company).profit+=1
            t=s.cargo(a).x-1 'type of cargo
            basis(st).inv(t).v=basis(st).inv(t).v+1  
            s.cargo(a).x=1
            'dprint "sold " &t
        endif
    next
    return s
end function

function load_s(s as _ship, good as short, st as short) as short
    dim as short bay,result,a
    for a=1 to 25
        if s.cargo(a).x=1 and bay=0 then bay=a
    next
    if bay=0 then result=-1
    if bay>0 then
        result=bay
        basis(st).inv(good).v=basis(st).inv(good).v-1
        s.cargo(bay).x=s.cargo(bay).x+good
        'dprint "bought " &good &" stored in "& bay &" Inv:"& basis(st).inv(good).v 
    endif
    return result
end function


function trading(st as short) as short
    dim a as short
    screenset 1,1
    check_tasty_pretty_cargo
    if st<3 then
        do
            set__color(11,0)
            a=menu(bg_trading+st," /Buy/Sell/Price development/Stock Market/Exit",,2,14)
            if a=1 then buygoods(st)
            if a=2 then sellgoods(st)
            if a=3 then showprices(st)
            if a=4 then stockmarket(st)
        loop until a=5
    else
        do
            set__color(11,0)
            if st<>10 then a=menu(bg_trading+st," /Buy/Sell/Exit",,2,14,,st)
            if st=10 then a=menu(bg_trading+st," /Plunder/Leave behind/Exit",,2,14)
            if a=1 then buygoods(st)
            if a=2 then sellgoods(st)
        loop until a=3
    endif
    set__color(11,0)
    cls
    return 0
end function

function showprices(st as short) as short
    dim as short a,b,highest,relhigh(9),relative
    do
        highest=0
        for a=0 to 9
            relhigh(a)=0
        next
        set__color(11,0)
        cls
        set__color( 11,0)
        for a=0 to 9
        set__color( a+8,0)
        if a=0 then 
            set__color( 11,0)
            draw string (0,a*_fh2),"Turn :",,font2,custom,@_col
        else
            draw string (0,a*_fh2),goodsname(a) &":",,font2,custom,@_col
        endif
        for b=0 to 11
            draw string ((b*5)*_fw2+15*_fw2,a*_fh2),""&goods_prices(a,b,st),,font2,custom,@_col
            if goods_prices(a,b,st)>relhigh(a) then relhigh(a)=goods_prices(a,b,st)
            if goods_prices(a,b,st)>highest then highest=goods_prices(a,b,st) 
        next
    next
    if relative=0 then
        for a=1 to 9
            for b=0 to 10
                set__color( a+8,0)
                line (b*(5*_fw2)+15*_fw2,(highest-goods_prices(a,b,st))/20+20*_fh2+a)-((b+1)*(5*_fw2)+15*_fw2,(highest-goods_prices(a,b+1,st))/20+20*_fh2+a)
            next
            draw string (0,(highest-goods_prices(a,0,st))/21+20*_fh2+a*2),goodsname(a) &":",,font2,custom,@_tcol
            
        next
    else
        for a=1 to 9
            for b=0 to 10
                set__color( a+8,0)
                line (b*(5*_fw2)+15*_fw2,(goods_prices(a,b,st)/relhigh(a))*50+20*_fh2+a)-((b+1)*(5*_fw2)+15*_fw2,(goods_prices(a,b+1,st)/relhigh(a))*50+20*_fh2+a)
            next
            draw string (0,(goods_prices(a,0,st))/relhigh(a)*50+20*_fh2+a*2),goodsname(a) &":",,font2,custom,@_tcol
            
        next

    endif
    no_key=keyin
    if no_key="a" then relative=0
    if no_key="r" then relative=1
    loop until no_key=key__esc
    return 0
end function


function buygoods(st as short) as short
    dim a as short
    dim c as short
    dim m as short
    dim d as short
    dim p as short
    dim f as short
    dim text as string
    
    text=station_goods(st,0)
    set__color(11,0)
    c=menu(bg_ship,text,"",2,3)
    if c<10 then
        m=basis(st).inv(c).v
        if basis(st).inv(c).v>0 then
            if m>getfreecargo() then m=getfreecargo
            if m>0 then
                display_ship
                displaywares(st)
                if st<>10 then dprint "how many tons of "& goodsname(c) &" do you want to buy?"
                if st=10 then dprint "how many tons of "& goodsname(c) &" do you want to transfer?"
                d=getnumber(0,m,0)
                p=basis(st).inv(c).p
                if d>0 and d<=m then 
                    if paystuff(p*d) then
                        for a=1 to d
                            f=getnextfreebay
                            player.cargo(f).x=c+1
                            player.cargo(f).y=p
                        next
                        if d=1 then 
                            if st=10 then
                                dprint "You transfer a ton of "& goodsname(c) &"."
                            else
                                dprint "You buy a ton of "& goodsname(c) &" for "& credits(p*d) &" Cr."
                            endif
                        endif
                        if d>1 then
                            if st=10 then
                                dprint "You transfer "& d & " tons of "& goodsname(c) &"."
                            else
                                dprint "You buy "& d & " tons of "& goodsname(c) &" for "& credits(p*d) &" Cr."
                            endif
                        endif
                        basis(st).inv(c).v=basis(st).inv(c).v-d
                    endif
                endif
            else
                dprint "No room for additional cargo.",14
                no_key=keyin
            endif
        endif
    endif
    display_ship
    return 0
end function

function get_invbay_bytype(t as short) as short
    dim as short a
    for a=1 to 10
        if player.cargo(a).x=t+1 then return a
    next
    return -1
end function

function merchant() as single
    dim as single m
    m=(70+5*crew(1).talents(6))/100
    if _debug=1 then dprint "MT"&m
    if m>0.9 then merchant=0.9
    if _debug=1 then dprint "MT"&m
    return m
end function

function sellgoods(st as short) as short
    dim text as string
    dim a as short
    dim b as short
    dim c as short
    dim em as short
    dim sold as short
    dim m as short
    dim as short mt,bay,ct,i    
    
    
    do
        if st=10 then
            text=cargobay("Leave behind:/",10,1)
        else
            text=cargobay("Sell:/",st,1)
        endif
        b=0
        em=0
        for a=1 to 25
            if player.cargo(a).x>=1 then b=b+1
            if player.cargo(a).x>1 then em=em+1
        next
        set__color(11,0)
        if em>0 then
            c=menu(bg_trading+st,text,,2,14)
            if c>0 and c<=b then
                if player.cargo(c).x>1 and player.cargo(c).x<25 then
                    ct=player.cargo(c).x-1
                    m=getinvbytype(ct) ' wie viele insgesamt
                    if player.cargo(c).x<=10 then
                        if st<>10 then 
                            dprint "how many tons of "& goodsname(ct) &" do you want to sell?"
                        else
                            dprint "how many tons of "& goodsname(ct) &" do you want to leave behind?"
                        endif
                        sold=getnumber(0,m,0)
                        if _debug=5 then dprint "Sold:"&sold
                        if sold>0 then
                            for i=1 to sold
                                bay=get_invbay_bytype(ct)
                                dprint "Unloading " & goodsname(ct) &" in bay "& bay &"."
                                if player.cargo(bay).y=0 then
                                    addmoney(basis(st).inv(ct).p*merchant,mt_piracy)
                                else
                                    addmoney(basis(st).inv(ct).p*merchant,mt_trading)
                                endif
                                basis(st).inv(ct).v=basis(st).inv(ct).v+1
                                player.cargo(bay).x=1
                                player.cargo(bay).y=0
                            next
                            if st<>10 then dprint "Sold " & sold & " tons of " & goodsname(Ct) & " for " & cint(basis(st).inv(ct).p*sold*merchant) &" Cr."
                            'removeinvbytype(player.cargo(c).x-1,sold)
                            'no_key=keyin
                            'c=b+1
                        endif
                    endif
                endif
            endif
        else
            c=-1
        endif
        if em=0 then dprint "Your cargo bays are empty.",c_yel
        if c=b+1 then
            if askyn("Do you really want to sell all?(y/n)") then
                for i=1 to 10
                    if player.cargo(i).x>1 and player.cargo(i).x<10  then
                        ct=player.cargo(i).x-1
                        if player.cargo(i).y=0 then
                            addmoney(basis(st).inv(ct).p*merchant,mt_piracy)
                        else
                            addmoney(basis(st).inv(ct).p*merchant,mt_trading)
                        endif
                        dprint "You sell a ton of "& goodsname(ct) &" for "&credits(basis(st).inv(ct).p*merchant) &" Cr."
                        player.cargo(i).x=1
                        player.cargo(i).y=0
                    else
                        if player.cargo(i).x>1 then dprint "Can't sell cargo in bay "&i &".",c_yel
                    endif
                next
            endif
        endif
        if _debug=1 then dprint "c:"&c &"b:"& b
    loop until c>=b+2 or c=-1 or em=0
    display_ship
    return 0
end function

function displaywares(st as short) as short
    textbox(station_goods(st,1),2,3,(_mwx*_fw1-4*_fw1)/_fw2)
'    dim a as short
'    dim t as string
'    dim as single pricelevel,merchant
'    pricelevel=basis(st).pricelevel
'    merchant=(80+5*crew(1).talents(6))/100
'    if merchant>pricelevel then merchant=pricelevel-0.05
'    set__color( 15,0 )
'    draw string (2*_fw1,2*_fh1),"Wares",,font2,custom,@_col
'    draw string (2*_fw1+22*_fw2,2*_fh1),"Price",,font2,custom,@_col
'    draw string (2*_fw1+35*_fw2,2*_fh1),"Qut.",,font2,custom,@_col
'    draw string (2*_fw1+17*_fw2,2*_fh1+_fh2),"Buy",,font2,custom,@_col
'    draw string (2*_fw1+25*_fw2,2*_fh1+_fh2),"Sell",,font2,custom,@_col
'    for a=1 to 9
'        set__color( 11,0)
'        draw string(2*_fw1+3*_fw2,3*_fh1+a*_fh2),basis(st).inv(a).n,,font2,custom,@_col
'        draw string(2*_fw1+18*_fw2,3*_fh1+a*_fh2),credits(int(basis(st).inv(a).p*pricelevel)),,font2,custom,@_col
'        draw string(2*_fw1+26*_fw2,3*_fh1+a*_fh2),credits(int(basis(st).inv(a).p*merchant)),,font2,custom,@_col
'        if basis(st).inv(a).v<10 then
'            draw string(2*_fw1+34*_fw2,3*_fh1+a*_fh2)," "& basis(st).inv(a).v,,font2,custom,@_col
'        else
'            draw string(2*_fw1+34*_fw2,3*_fh1+a*_fh2),""& basis(st).inv(a).v,,font2,custom,@_col
'        endif
'    next
    
    return 0
end function

function getfreecargo() as short
    dim re as short
    dim a as short
    for a=1 to 10
        if player.cargo(a).x=1 then re=re+1
    next
    return re
end function

function getnextfreebay() as short
    dim re as short
    dim a as short
    dim b as short
    for a=1 to 10
        if player.cargo(a).x=1 then return a
    next
    return -1
end function

function check_tasty_pretty_cargo() as short
    dim as short freebay
    freebay=getnextfreebay
    if freebay>0 then
        if reward(rwrd_pretty)>=100 then
            dprint "You have collected enough beautiful animal parts to produce a cargo ton of luxury items"
            if askyn("Do you want to do so?(y/n)") then
                reward(rwrd_pretty)-=100
                player.cargo(freebay).x=4
                player.cargo(freebay).y=0
                freebay=getnextfreebay
            endif
        endif
    endif
    
    if freebay>0 then
        if reward(rwrd_tasty)>=100 then
            dprint "You have collected enough tasty animal parts to produce a cargo ton of food!"
            if askyn("Do you want to do so?(y/n)") then
                reward(rwrd_tasty)-=100
                player.cargo(freebay).x=2
                player.cargo(freebay).y=0
            endif
        endif
    endif
return 0
end function


function nextemptyc() as short
dim re as short
    dim a as short
    dim b as short
    for a=1 to 10
        if player.cargo(a).x=0 and b=0 then b=a
    next
    return b
end function

function change_prices(st as short,etime as short) as short
    dim a as short
    dim b as short
    dim c as short
    dim supply as short
    dim demand as short
    dim change as short
    dim as short debug=1
    dim c1 as single
    dim c2 as single
    dim c3 as single
    for a=1 to 8
        'basis(st).inv(a).test2=basis(st).inv(a).p
        supply=0
        demand=0
        for b=1 to etime
            if a<6 then
                supply=supply+rnd_range(1,8-a)
                if basis(st).company=3 then supply+=1
            else
                if st<=5 then
                    if basis(st).company=1 and a=8 then 
                        supply=supply+rnd_range(1,2)
                        demand-=1
                    endif
                    if basis(st).company=2 and a=7 then 
                        supply=supply+rnd_range(1,2)
                        demand-=1
                    endif
                    if basis(st).company=4 and a=6 then 
                        supply=supply+rnd_range(1,2)
                        demand-=1
                    endif
                    'TT can't make the stuff
                else
                    demand=-4
                    supply=0
                endif
            endif
            demand=demand+rnd_range(1,6)
        next
        change=supply-demand
        basis(st).inv(a).v=basis(st).inv(a).v+change
        change=demand-supply
        if change>5 then change=5
        if change<-5 then change=-5
        if basis(st).inv(a).v<0 then
            basis(st).inv(a).v=0
            change=change+2
        endif
        if basis(st).inv(a).v>10 then
            basis(st).inv(a).v=10
            change=change-2
        endif
        'market extremes
        basis(st).inv(a).p=basis(st).inv(a).p+fix(basis(st).inv(a).p*change/10)
        if basis(st).inv(a).p<baseprice(a)/2 then 
            basis(st).inv(a).p=baseprice(a)/2
            basis(st).inv(a).v=basis(st).inv(a).v-rnd_range(1,3)
        endif
        if basis(st).inv(a).v<1 then basis(st).inv(a).v=rnd_range(1,3)
        if basis(st).inv(a).p>baseprice(a)*2 then 
            basis(st).inv(a).v=basis(st).inv(a).v+rnd_range(1,3)
            basis(st).inv(a).p=baseprice(a)*2
        endif
        
    next
    
    'gasprice
    for b=1 to etime step 10
        supply=rnd_range(0,2)+rnd_range(0,count_gas_giants_area(basis(st).c,7))
        'supply=((2+count_gas_giants_area(basis(st).c,10))*basis(st).inv(9).p/30)-rnd_range(0,3)
        if basis(st).inv(9).v+supply>7 then basis(st).inv(9).p-=rnd_range(1,3)
        if basis(st).inv(9).v+supply<3 then basis(st).inv(9).p+=rnd_range(1,3)
        if basis(st).inv(9).v+supply<0 then basis(st).inv(9).p+=1
        basis(st).inv(9).v+=supply
        if basis(st).inv(9).v<1 then basis(st).inv(9).v=1
        if basis(st).inv(9).v>10 then basis(st).inv(9).v=10
        if basis(st).inv(9).p<20 then basis(st).inv(9).p=20 
        if basis(st).inv(9).p>300 then basis(st).inv(9).p=300 
        if debug=1 and _debug=1 then dprint "Price st "&st &":"& basis(st).inv(9).p
    next
    for c=12 to 1 step -1
        goods_prices(0,c,st)=goods_prices(0,c-1,st)
    next
    goods_prices(0,c,st)=player.turn
    for b=1 to 8
        for c=12 to 1 step -1
            goods_prices(b,c,st)=goods_prices(b,c-1,st)
        next
        goods_prices(b,0,st)=basis(st).inv(b).p
        avgprice(b)=0
        for a=0 to 4
            if a<>3 then
                avgprice(b)=avgprice(b)+basis(a).inv(b).p
            endif
        next
        avgprice(b)=avgprice(b)/4
    next
    return 0
end function

function rarest_good() as short
    dim as short j,i,good(lastgood)
    for j=0 to 3
        for i=1 to lastgood
            good(i)+=basis(j).inv(i).v
        next
    next
    return find_low(good(),lastgood)
end function

function station_goods(st as short, tb as byte) as string
    dim as string text,pl,LR
    dim a as short
    dim off as short
    if tb=0 then 'Textbox or menu
        LR="/"
        text=space(25)&"Buy        Sell"&LR
    else
        LR="|"
        
        text="{15}"&space(25)&"Buy        Sell"&LR &"{11}"
    endif
    for a=1 to 9
        if tb=1 then text=text &"   "
        text=text & trim(goodsname(a))&space(17-len(trim(goodsname(a)))) 
        pl=""& credits(basis(st).inv(a).p) &" Cr."
        text=text & space(12-len(pl))
        text=text & pl
        
        pl=""& credits(cint(basis(st).inv(a).p*merchant))&" Cr."
        text=text & space(12-len(pl))
        text=text & pl &space(4)
        if basis(st).inv(a).v>=10 then
            text=text & basis(st).inv(a).v
        else
            text=text & " "& basis(st).inv(a).v
        endif
        text=text & LR
    next
    if tb=0 then text=text & "Exit"
    return text
end function

function cargobay(text as string,st as short,sell as byte=0) as string
    dim a as short
    
    for a=1 to 10        
        if player.cargo(a).x=1  then text=text &"Empty/"
        if player.cargo(a).x>1 and player.cargo(a).x<=10 then
            text=text & goodsname(player.cargo(a).x-1) &" for " &credits(cint(basis(st).inv(player.cargo(a).x-1).p*merchant)) &" Cr.," 
            if player.cargo(a).y=0 then
                text=text &" found/"
            else
                text=text & " bought at " &credits(player.cargo(a).y) &" Cr./"
            endif
        endif
        if player.cargo(a).x=11 then text=text &"Sealed Box/"
        if player.cargo(a).x=12 then text=text &"TriaxTraders Cargo/"
    next
    if sell=1 then
        text=text &"Sell all/"
    endif
    text=text &"Exit"
    return text
end function

function getinvbytype(t as short) as short
    dim a as short
    dim r as short
    t=t+1
    for a=1 to 10
        if player.cargo(a).x=t then
            r=r+1
        endif
    next
    return r
end function

function removeinvbytype( t as short, am as short) as short
    dim a as short
    dim b as short
    t=t+1
    for a=1 to 25
        if player.cargo(a).x=t and am>0 then
            player.cargo(a).x=1
            am=am-1
        endif
    next
    return am
end function

function recalcshipsbays() as short
    dim soll as short
    dim haben as short
    dim as short a,b,c
    dim del as _crewmember
    dim dif as short
    
    for c=0 to 9
        for b=1 to 9
            if player.weapons(b).desig="" then swap player.weapons(b),player.weapons(b+1) 
            'if player.cargo(b).x<player.cargo(b+1).x then swap player.cargo(b),player.cargo(b+1)
        next
    next
    player.fuelpod=0
    player.crewpod=0
    soll=player.h_maxcargo
    for a=1 to 10
        if a>player.h_maxweaponslot then player.weapons(a)=makeweapon(-1)
        if player.weapons(a).desig="Cargo Bay" then soll=soll+1
        if player.weapons(a).desig="Fuel Tank" then player.fuelpod=player.fuelpod+50
        if trim(player.weapons(a).desig)="Crew Quarters" then player.crewpod=player.crewpod+10
    next
    for a=1 to 25
        if player.cargo(a).x>0 then haben=haben+1
    next
    if soll>haben then
        dif=soll-haben
        do
        for a=1 to 25
            if player.cargo(a).x=0 and dif>0 then
                player.cargo(a).x=1
                dif=dif-1
            endif
        next
        loop until dif<=0
    endif
    if haben>soll then
        dif=haben-soll
        for b=1 to 5
            for a=1 to 25
                if player.cargo(a).x=b and dif>0 then
                    player.cargo(a).x=0 
                    dif=dif-1
                endif
            next
        next
    endif
    for c=1 to 9
        for b=1 to 9
          if player.cargo(b).x<player.cargo(b+1).x then swap player.cargo(b),player.cargo(b+1)
      next        
    next
    if player.fuel>player.fuelmax+player.fuelpod then player.fuel=player.fuelmax+player.fuelpod
    for c=6 to player.h_maxcrew+player.crewpod+player.cryo
        if crew(c).hp<>0 then player.security=c
    next
    for c=5+player.cryo+(player.h_maxcrew+player.crewpod-5)*2+1 to 128
        crew(c)=del
    next    
    player.addhull=0
    for a=1 to 5
        if player.weapons(a).made=87 then player.addhull=player.addhull+5
    next
    if player.hull>max_hull(player) then player.hull=max_hull(player)
    return 0
end function

function paystuff(price as integer) as integer
    if player.money<price then
        dprint "you dont have enough money",c_yel
        return 0
    else
        player.money=player.money-price 'Paystuff
        return -1
    endif
end function

function addmoney(amount as integer,mt as byte) as short
    player.money+=amount
    income(mt)+=amount
    return 0
end function


function shop(sh as short,pmod as single,shopn as string) as short
    dim as short a,b,c,e,v,i,best,order,ex
    dim as string t
    dim inv(20) as _items
    dim lonest as short
    dim desc as string
    dim l as string
    c=1
    i=20
    order=-2
    t=shopn
    pmod=pmod*haggle_("DOWN")
    for a=1 to 9999
        for b=1 to i
            if shopitem(b,sh).ty=a then
                inv(c)=shopitem(b,sh)
                c=c+1
            endif
        next
    next
        
    sort_items(inv())
    
    for b=1 to i
        for a=1 to i-1
            if inv(a).desig="" then inv(a)=inv(a+1)
        next
    next
    b=1
        
    for a=1 to c-1
        t=t &"/" &inv(a).desig & space(_swidth-len(trim(inv(a).desig))-len(credits(inv(a).price*pmod))) & credits(int(inv(a).price*pmod)) &" Cr." 
        desc=desc &"/"&inv(a).ldesc
        b=b+1
    next
    if sh<=3 then
        order=b
        b+=1
        t=t &"/Order Item"
        desc=desc &"/Order an item not in stock for double the price"
    endif
    ex=b
    t=t & "/Exit"
    desc=desc &"/"
    display_ship()
    dprint("")
    c=menu(bg_parent,t,desc,2,2)
    select case c
    case order
        place_shop_order(sh)
    case ex,-1
        return -1
    case else
        select case inv(c).ty
        case 150'sensors
            if inv(c).v1<player.sensors then dprint "You already have better sensors."
            if inv(c).v1=player.sensors then dprint "These sensors aren't better than the one you already have."
            if inv(c).v1>player.h_maxsensors then dprint "These sensors don't fit in your ship."
            if inv(c).v1>player.sensors and inv(c).v1<=player.h_maxsensors then
                if paystuff(inv(c).price*pmod) then 
                    player.sensors=inv(c).v1
                    dprint "You buy a "&inv(c).desig &"."
                endif
            endif
        case 151'engine
            if inv(c).v1<player.engine then dprint "You already have a better engine."
            if inv(c).v1=player.engine then dprint "this engine isn't better than the one you already have."
            if inv(c).v1>player.h_maxengine then dprint "This engine doesn't fit in your ship."
            if inv(c).v1>player.engine and inv(c).v1<=player.h_maxsensors then
                if paystuff(inv(c).price*pmod) then
                    player.engine=inv(c).v1
                    dprint "You buy a "&inv(c).desig &"."
                endif
            endif
        case 152'shield
            if inv(c).v1<player.shieldmax then dprint "You already have a better shieldgenerator."
            if inv(c).v1=player.shieldmax then dprint "This shield generator isn't better than the one you already have."
            if inv(c).v1>player.h_maxshield then dprint "This shield generator doesn't fit in your ship."
            if inv(c).v1>player.shieldmax and inv(c).v1<=player.h_maxsensors then
                if paystuff(inv(c).price*pmod) then
                    player.shieldmax=inv(c).v1
                    dprint "You buy a "&inv(c).desig &"."
                endif
            endif
        case 153 'Shipdetection
            if inv(c).v1<player.equipment(se_shipdetection) then dprint "You already have a better ship detection system."
            if inv(c).v1=player.equipment(se_shipdetection) then dprint "You already have the same ship detection system."
            if inv(c).v1>player.equipment(se_shipdetection) then 
                if paystuff(inv(c).price*pmod) then 
                    player.equipment(se_shipdetection)=inv(c).v1
                    dprint "You buy a "&inv(c).desig &"."
                endif
            endif
        case 154 'navcomp
            if inv(c).v1=player.equipment(se_navcom) then dprint "You already have a navigational computer."
            if inv(c).v1>player.equipment(se_navcom) then 
                if paystuff(inv(c).price*pmod) then 
                    player.equipment(se_navcom)=inv(c).v1
                    dprint "You buy a "&inv(c).desig &"."
                endif
            endif
            
        case 155 'ECM
            if inv(c).v1<player.equipment(se_ECM) then dprint "You already have a better ECM system."
            if inv(c).v1=player.equipment(se_ECM) then dprint "You already have the same ECM system."
            if inv(c).v1>player.equipment(se_ECM) then 
                if paystuff(inv(c).price*pmod) then 
                    player.equipment(se_ECM)=inv(c).v1
                    dprint "You buy a "&inv(c).desig &"."
                endif
            endif
            
        case 156 'Cargoshielding
            if inv(c).v1<player.equipment(se_CargoShielding) then dprint "You already have better cargo shielding."
            if inv(c).v1=player.equipment(se_CargoShielding) then dprint "You already have the same cargo shielding."
            if inv(c).v1>player.equipment(se_CargoShielding) then 
                if paystuff(inv(c).price*pmod) then player.equipment(se_CargoShielding)=inv(c).v1
            endif
        case 157 'Fuelsystem
            if inv(c).v1<player.equipment(se_Fuelsystem) then dprint "You already have a better fuel system."
            if inv(c).v1=player.equipment(se_Fuelsystem) then dprint "You already have the same fuel system."
            if inv(c).v1>player.equipment(se_Fuelsystem) then 
                if paystuff(inv(c).price*pmod) then 
                    player.equipment(se_fuelsystem)=inv(c).v1
                    player.fueluse=1-inv(c).v1/10
                    dprint "You buy " &add_a_or_an(inv(c).desig,0) & "."
            
                endif
            endif
        case 21
            best=findbest(21,-1)
            if best>0 then
                if item(best).v1>inv(c).v1 then dprint "you already have a better infirmary"
                if item(best).v1=inv(c).v1 then dprint "you already have such an infirmary"
                if item(best).v1<inv(c).v1 then 
                    if paystuff(inv(c).price*pmod) then 
                        placeitem(inv(c),0,0,0,0,-1)'player already has one and t his one is better
                        dprint "You buy " &add_a_or_an(inv(c).desig,0) & "."
            
                    endif
                endif
            else
                if paystuff(inv(c).price*pmod) then 
                    placeitem(inv(c),0,0,0,0,-1)'Its the first
                    dprint "You buy " &add_a_or_an(inv(c).desig,0) & "."
            
                endif
            endif
        
        case else
            if paystuff(int(inv(c).price*pmod))=-1 then
                player.money=player.money+int(inv(c).price*pmod)'Giving back
                dprint "How many "&inv(c).desigp &" do you want to buy? (Max: " &fix(player.money/(inv(c).price*pmod)) &")"
                v=getnumber(0,fix(player.money/(inv(c).price*pmod)),0)
                if v>0 then
                    if paystuff(inv(c).price*pmod*v)=-1 and v>0 then
                        for a=1 to v
                            uid+=1
                            inv(c).uid=uid
                            placeitem(inv(c),0,0,0,0,-1)
                        next
                        if v=1 then
                            dprint "you buy "&add_a_or_an(inv(c).desig,0) & " for "& credits(int(inv(c).price*pmod))&" Cr."
                        else
                            dprint "you buy "& v &" "&inv(c).desigp &" for "&credits(int(inv(c).price*pmod*v)) &" Cr."
                        endif
                    endif
                endif
            endif
        end select
    end select
    return c
end function

function place_shop_order(sh as short) as short
    dim as string t,w
    dim as short a,b,f
    dim as single bestmatch,bmc,candidate,s,l
    dim tried(80) as byte
    dim as _cords p
    dim as _items i
    p=locEOL
    dprint "What would you like to order?"
    t=gettext(p.x,p.y,26,t)
    t=ucase(t)
    f=0
    do
    bestmatch=9999
    f+=1
    for a=1 to 80
        i=makeitem(a)
        i.desig=ucase(i.desig)
        l=len(i.desig)
        w=""
        if trim(ucase(i.desig))=trim(ucase(t)) and tried(a)=0 then
            candidate=a
            bestmatch=0
        else
            for b=1 to l
                w=w &mid(i.desig,b,1)
                print #f,w
                if mid(i.desig,b,1)=" " or b=l then
                    s=fuzzymatch(w,t)
                    if s<bestmatch and tried(a)=0 then
                        candidate=a
                        bestmatch=s
                    endif
                    print #f,"score:";s;"Words:";t;":";w
                    w=""
                endif
            next
        endif
    next
    if bestmatch<0.2 then
        i=makeitem(candidate)
        if askyn("Do you want to order "&add_a_or_an(i.desig,0) &"? (y/n)") then
            shop_order(sh)=candidate
            dprint "I can't say for certain when it will arive, but it should be here soon."
            f=3
            candidate=0
        else
            tried(candidate)=1
        endif
    else
        dprint "I don't think I ever heard of those."
        f=3
    endif
    loop until f=3
    return 0
end function


Function fuzzymatch( s As String, t As String ) As single
dim as string dic
Dim As Integer k, i, j, n, m, cost
dim as single dis
Dim As Integer Ptr d
dim as short  f
    f=freefile
    open "data/dictionary.txt" for input as #f
    while not eof(f)
        line input #f,dic
        if ucase(trim(t))=ucase(trim(dic)) then t=""
    wend
    close f
   s=trim(s)
   t=trim(t)
n = Len(s)
m = Len(t)

If (n <> 0) And (m <> 0) Then
   
   d = allocate( sizeof(Integer) * (m+1) * (n+1) )
   m += 1
   n += 1
   k = 0

   While k < n
      d[k]=k
      k += 1
   Wend

   k = 0
   While k < m
      d[k*n]=k
      k += 1
   Wend

   i = 1
   While i < n
      j = 1

      While j<m
         If (s[i-1] = t[j-1]) Then
            cost = 0

         Else
            cost = 1

         End If

         d[j*n+i] = lev_minimum(d[(j-1)*n+i]+1, d[j*n+i-1]+1, d[(j-1)*n+i-1]+cost)

         j += 1
      Wend

      i += 1
   Wend

   dis = d[n*m-1]
   deallocate d
    if n>m then 
        dis=dis/n
    else
        dis=dis/m
    endif
   Return dis

Else
   Return -1

End If

End Function

Function lev_minimum( a As Integer, b As Integer, c As Integer ) As Integer

var min = a

If (b<min) Then min = b
If (c<min) Then min = c

Return min

End Function

function reroll_shops() as short
    dim as short a,b,i,c,sh,flag,roll,spec,shopno
    dim  as _items it,delit
    dim sortinvlist(20) as _items
    dim dummynumber(20) as short
    for shopno=0 to 29
        for a=0 to 20
            shopitem(a,shopno)=delit 'Delete Item
        next
    next
    
    for i=0 to 24
        if i<>20 then
        b=0
        a=1
        do
            b+=1
            flag=0
            it=delit 'Delete Item
            if i<=3 then 'Station Shops
                spec=basis(i).shop(sh_equipment)
                if a<=5 then
                    it=rnd_item(RI_StandardShop)
                else
                    if spec=1 then it=rnd_item(RI_ShopExplorationGear)
                    if spec=2 then 
                        if rnd_range(1,100)<50 then 
                            it=rnd_item(RI_WeakWeapons)
                        else
                            it=rnd_item(RI_WeakStuff)
                        endif
                    endif
                    if spec=3 then it=rnd_item(RI_ShopSpace)
                    if spec=4 then it=rnd_item(RI_ShopWeapons)
                endif
            endif
            if i=4 then 'Colony I
                if b=19 then it=makeitem(97)'Disintegrator
                if b=18 then it=makeitem(98)'adaptive bodyarmor
                if b<17 then
                    it=makeitem(RI_Standardshop)
                endif
            endif
            if i=6 then 'Black market
                it=rnd_item(RI_AllButWeaponsAndMeds)
            endif
            if i=7 then 'Mudds
                if b=1 then 
                    it=makeitem(250)
                else
                    it=makeitem(rnd_range(1,80))
                endif
            endif
            if i=5 or (i>7 and i<21) then
                if a<=3 then
                    it=makeitem(31+a)
                endif
                it=rnd_item(RI_StandardShop)
            endif
            
            if i>=21 and i<=24 then 'Medical supplies
                select case rnd_range(1,100)
                case 1 to 18
                    it=rnd_item(RI_Infirmary)
                case 19 to 60
                    it=rnd_item(RI_Medpacks)
                case 61 to 80
                    it=rnd_item(RI_KODrops)
                case else
                    it=rnd_item(RI_Cage)
                end select
            endif
            
            for c=1 to 20
                if shopitem(c,i).desig="" then
                    shopitem(c,i)=it
                    a+=1
                    exit for
                endif
                if shopitem(c,i).id=it.id then exit for
            next
        loop until a>=20 or (i=20 and a>=15) or (i>=21 and a>=10)
        endif
    next
    
    'Engine Sensors Shieldshop
    a=0
    roll=rnd_range(1,90)+player.turn/250
    if roll>0 then 
        a+=1
        shopitem(a,20)=make_shipequip(1)
    endif
    if roll>10 then 
        a+=1
        shopitem(a,20)=make_shipequip(2)
    endif
    if roll>25 then 
        a+=1
        shopitem(a,20)=make_shipequip(3)
    endif
    if roll>75 then 
        a+=1
        shopitem(a,20)=make_shipequip(4)
    endif
    if roll>90 then 
        a+=1
        shopitem(a,20)=make_shipequip(5)
    endif
    
    roll=rnd_range(1,90)+player.turn/250
    if roll>0 then 
        a+=1
        shopitem(a,20)=make_shipequip(6)
    endif
    if roll>10 then 
        a+=1
        shopitem(a,20)=make_shipequip(7)
    endif
    if roll>25 then 
        a+=1
        shopitem(a,20)=make_shipequip(8)
    endif
    if roll>75 then 
        a+=1
        shopitem(a,20)=make_shipequip(9)
    endif
    if roll>90 then 
        a+=1
        shopitem(a,20)=make_shipequip(10)
    endif
    
    roll=rnd_range(1,90)+player.turn/250
    if roll>10 then 
        a+=1
        shopitem(a,20)=make_shipequip(11)
    endif
    if roll>25 then 
        a+=1
        shopitem(a,20)=make_shipequip(12)
    endif
    if roll>75 then 
        a+=1
        shopitem(a,20)=make_shipequip(13)
    endif
    if roll>90 then 
        a+=1
        shopitem(a,20)=make_shipequip(14)
    endif
    for b=15 to 23
        if rnd_range(1,100)<50 and a<=19 then 
            a+=1
            shopitem(a,20)=make_shipequip(b)
        endif
    next
    a+=1
    if a>20 then a=20
    shopitem(a,20)=make_shipequip(21)
    'Droneshop
    c=1
    
    for b=50 to 55 
        if rnd_range(1,100)<77 then
            shopitem(c,25)=makeitem(b)
            c+=1
        endif
    next
    if rnd_range(1,100)<77 then 
        c+=1
        shopitem(c,25)=makeitem(30)'Comsat
    endif
    
    for b=100 to 102
        if rnd_range(1,100)<77 then
            shopitem(c,25)=makeitem(b,,25)
            c+=1
        endif
    next
    
    for b=104 to 105
        if rnd_range(1,100)<77 then
            shopitem(c,25)=makeitem(b)
            c+=1
        endif
    next
    
    for b=110 to 112
        if rnd_range(1,100)<77 then
            shopitem(c,25)=makeitem(b,,25)
            c+=1
        endif
    next
    
    for b=0 to 3 'Module Stores in spacestations
        for i=1 to 10
            select case basis(b).shop(sh_modules)
            case ms_energy
                makew(i,b)=rnd_range(6,10)
            case ms_projectile
                makew(i,b)=rnd_range(1,5)
            case ms_modules
                if rnd_range(1,100)<66 then
                    makew(i,b)=rnd_range(84,99)
                else
                    makew(i,b)=rnd_range(97,99)
                endif
            end select
        next
        for i=11 to 15
            makew(i,b)=rnd_range(84,99)
        next
        c=16
        for i=16 to 19
            if rnd_range(1,100)<20+player.turn/100 then
                select case rnd_range(1,100)
                case 1 to 33
                    makew(c,b)=rnd_range(4,5)
                case 34 to 66
                    makew(c,b)=rnd_range(9,10)
                case else
                    makew(c,b)=rnd_range(84,99)
                end select
                c+=1
            endif
        next
    next
    
    
    for b=4 to 5 'Shipweapons shops
        i=0
        c=0
        if b=5 then sh=1
        for a=1 to 4+sh
            if rnd_range(1,100)<(130-(c*10)+(sh*20)) then
                i=i+1
                if i>20 then i=20
                makew(i,b)=a
            endif
            c=c+1
        next
        c=0
        for a=6 to 9+sh
            if rnd_range(1,100)<(130-(c*10)+(sh*20)) then
                i=i+1
                if i>20 then i=20
                makew(i,b)=a
            endif
            c=c+1
        next
        c=0
        if sh>0 then
            for a=11 to 14
                if rnd_range(1,100)<(100-(c*10)+(sh*20)) then
                    i=i+1
                    if i>20 then i=20
                    makew(i,b)=a
                endif
                c=c+1
            next
        endif
        
        for a=84 to 99
            if rnd_range(1,100)<55 then
                i+=1
                if i>20 then i=20
                makew(i,b)=a
            endif
        next
    next
    
    
    
    for b=26 to 29
        i=0
        i+=1
        shopitem(i,b)=makeitem(75)
        if rnd_range(1,100)<50 then
           i+=1
           shopitem(i,b)=makeitem(76)
        endif
        
        i+=1
        shopitem(i,b)=makeitem(104)
        if rnd_range(1,100)<25 then
           i+=1
           shopitem(i,b)=makeitem(105)
        endif
        
        i+=1
        shopitem(i,b)=makeitem(100)
        if rnd_range(1,100)<75 then
           i+=1
           shopitem(i,b)=makeitem(101)
        endif
        if rnd_range(1,100)<25 then
           i+=1
           shopitem(i,b)=makeitem(102)
        endif
        
        i+=1
        shopitem(i,b)=makeitem(110)
        if rnd_range(1,100)<75 then
           i+=1
           shopitem(i,b)=makeitem(111)
        endif
        if rnd_range(1,100)<25 then
           i+=1
           shopitem(i,b)=makeitem(112)
        endif
        
        'sort_items(shopitem(,b))
    next
    for i=1 to 8
        usedship(i).x=rnd_range(1,12)
        usedship(i).y=rnd_range(0,3)
    next
    return 0
end function

function buysitems(desc as string,ques as string, ty as short, per as single=1,aggrmod as short=0) as short
    dim as integer a,b,answer,price
    dim text as string
    if configflag(con_autosale)=0 then 
        dprint desc & " (autoselling on)"
    else
        dprint desc & " (autoselling off)"
    endif
    if ques<>"" then
        answer=askyn(ques)
    else
        answer=-1
    endif
    if _debug=1 then dprint "answer:"&answer
    if  answer=-1 then
        if configflag(con_autosale)=1 or ty=0 then
            do
                set__color(11,0)
                cls
                a=get_item()
                if a>0 then 
                    if (item(a).ty=ty or ty=0) and item(a).w.s=-1  then
                        if item(a).ty<>26 then
                            price=cint(item(a).price*per)
                        else
                            price=cint(item(a).v1*25*per)
                        endif
                        if configflag(con_autosale)=1 or b=0 then b=askyn("Do you want to sell the "&item(a).desig &" for "& price &" Cr.?(y/n)")             
                        if b=-1 then    
                            dprint "you sell the "&item(a).desig &" for " &price & " Cr."
                            addmoney(price,mt_trading)
                            reward(2)=reward(2)-item(a).v5               
                            factionadd(0,1,item(a).price/disnbase(player.c)/100*aggrmod)
                            factionadd(0,2,-item(a).price/disnbase(player.c)/100*aggrmod)
                            destroyitem(a)    
                            b=0
                        endif
                    endif
                endif
            loop until a<0
        else            
            for a=0 to lastitem
                if item(a).ty<>26 then
                    price=cint(item(a).price*per)
                else
                    price=cint(item(a).v1*50*per)
                endif
                if item(a).ty=ty and item(a).w.s=-1 then
                    text=text &"You sell the "&item(a).desig &" for "& price & " Cr. "
                    addmoney(price,mt_trading)
                    if item(a).ty=15 then reward(2)=reward(2)-item(a).v5                        
                    factionadd(0,1,item(a).price/disnbase(player.c)/100*aggrmod)
                    factionadd(0,2,-item(a).price/disnbase(player.c)/100*aggrmod)
                    destroyitem(a)
                endif
            next
            if text<>"" then
                dprint text
            else
                dprint "You couldn't sell anything."
            endif
            
        endif
    endif
    return 0
end function

    
