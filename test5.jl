using Plots 
using Statistics

struct Vec2
    x::Float64
    y::Float64
end

function Base.:+(v1::Vec2,v2::Vec2)
    a=v1.x+v2.x
    b=v1.y+v2.y
    res=Vec2(a,b)
    return res
end

function Base.:-(v1::Vec2,v2::Vec2)
    a=v1.x-v2.x
    b=v1.y-v2.y
    res=Vec2(a,b)
    return res
end

function Base.:*(v1::Vec2,v2::Vec2)
    a=v1.x*v2.x
    b=v1.y*v2.y
    res=Vec2(a,b)
    return res
end

function Base.:/(v1::Vec2,v2::Vec2)
    a=v1.x/v2.x
    b=v1.y/v2.y
    res=Vec2(a,b)
    return res
end

function equals(v1::Vec2,v2::Vec2)
    if v1.x == v2.x && v1.y == v2.y
        return true
    else
        return false
    end
end

function norm(v1::Vec2, v2::Vec2)
    n=sqrt((v1.x-v2.x)^2+(v1.y-v2.y)^2)
    return n
end

function vecmean(v::Vector{Vec2})
    x=[]
    y=[]
    for i in 1:length(v)
        push!(x, v[i].x)
        push!(y, v[i].y)
    end

    res=Vec2(mean(x),mean(y))
    return res
end

function vecsum(v::Vector{Vec2})
    x=[]
    y=[]
    for i in 1:length(v)
        push!(x, v[i].x)
        push!(y, v[i].y)
    end

    res=Vec2(sum(x),sum(y))
    return res
end
mutable struct Boid
    pos::Vec2
    speed::Vec2
    acceleration::Vec2
    viewarea::Float64
end

function return_to_borders(subj::Vec2,borders1::Vec2,borders2::Vec2)
    x=subj.x; y=subj.y

    if y>borders2.y
        y=borders2.y
    end
    if x>borders2.x
        x=borders2.x
    end
    if y<borders1.y
        y=borders1.y
    end
    if x<borders1.x
        x=borders1.x
    end

    subj=Vec2(x,y)
    return subj
end

function where_hit(subj::Vec2,borders1::Vec2,borders2::Vec2)
    xmin=borders1.x; ymin=borders1.y; xmax=borders2.x; ymax=borders2.y;
    result=0;

    if subj.y==ymax && subj.x==xmax || subj.y==ymin && subj.x==xmax || subj.y==ymax && subj.x==xmin || subj.y==ymin && subj.x==xmin # попадание в угол
        result=1
    elseif subj.y>=ymax || subj.y<=ymin # упёрся в верхний или нижний край
        result=2
    elseif subj.x>=xmax || subj.x<=xmin # упёрся в правый или левый край
        result=3
    end

    return result # 0 - никуда, 1 - в угол, 2 - в верхний или нижний край, 3 - в правый или левый край
end

# отскакивание от границ поля
function rebound(position::Vec2,speed::Vec2)
    borders1=Vec2(10,10); borders2=Vec2(290,290)
    dx=speed.x; dy=speed.y

    # проверка выхода за границы поля из-за выполнения правил
    position=return_to_borders(position,borders1,borders2)

    # проверка на столкновение с границами
    w=where_hit(position,borders1,borders2)

    if w==1     # попадание в угол
        dx*=-1; dy*=-1
    elseif w==2 # упёрся в верхний или нижний край
        dy*=-1
    elseif w==3 # упёрся в правый или левый край
        dx*=-1
    end

    speed = Vec2(dx,dy)
    return speed
end

function separation(position::Vec2,speed::Vec2,viewarea::Float64,all::Vector{Boid})
    acc = Vec2(0,0)
    di = Vec2[]
    k = 0

    n=length(all)
    for i in 1:n
        r=norm(position, all[i].pos)
        if r <= viewarea && !equals(position, all[i].pos)
            vi = Vec2(-1,-1)*(all[i].pos - position)
            push!(di, vi)
            k=1
        end
    end

    if k>0
        acc = vecsum(di) - speed
        # l = norm(mdi,position)
        # acc = ai/Vec2(l,l)
    end

    return acc
end

function cohesion(position::Vec2, speed::Vec2, viewarea::Float64,all::Vector{Boid})
    acc = Vec2(0,0)
    
    n = length(all)
    ipos = Vec2[]
    k = 0
    for i in 1:n
        r = norm(position, all[i].pos)
        if r <= viewarea && !equals(position, all[i].pos)
            push!(ipos, all[i].pos)
            k=1
        end
    end

    if k>0
        m = vecmean(ipos)
        vi = m - position # желаемая в этом случае скорость (длинны катетов)
        l = norm(m, position)
        acc = (vi - speed)/Vec2(l,l)
    end

    return acc
end

function alignment(position::Vec2,speed::Vec2,viewarea::Float64,all::Vector{Boid})
    acc = Vec2(0,0)
    
    n = length(all)
    di = Vec2[]
    k = 0

    for i in 1:n
        r=norm(position, all[i].pos)
        if r<=viewarea !equals(position, all[i].pos)
            push!(di, all[i].speed)
            k=1
        end
    end

    if k>0
        acc = vecsum(di) - speed
        # acc /= Vec2(100,100)
    end

    return acc
end

function speedcheck(speed::Vec2)
    v = sqrt(speed.x^2*speed.y^2)
    limit = 10
    if v > limit
        k = v/limit
        speed = speed/Vec2(k,k)
    end

    return speed
end

function rules(boid::Boid, all::Vector{Boid})
    position = boid.pos; speed = boid.speed; viewarea = boid.viewarea
    
    acc_cohesion = Vec2(0,0); acc_separation = Vec2(0,0); acc_alignment = Vec2(0,0); acc_res = Vec2(0,0)

    # acc_cohesion = cohesion(position, speed, viewarea,all)
    acc_separation = separation(position,speed,viewarea,all)
    # acc_alignment = alignment(position,speed,viewarea,all)

    acc_res = acc_cohesion + acc_separation + acc_alignment
    speed_res = speed + acc_res

    speed_res = rebound(position,speed_res)

    return speed_res,acc_res
end

function redraw(all::Vector{Boid})
    x = []
    y = []
    for i in 1:length(all)
        push!(x, all[i].pos.x)
        push!(y, all[i].pos.y)
    end
    scatter(x, y, markershape = :circle, ms=5, lab="", xlim=(0,300), ylim=(0,300))

    l = 5
    for i in 1:length(all)
        lr=sqrt(all[i].speed.x^2+all[i].speed.y^2)
        k=l/lr
        di = all[i].speed*Vec2(k,k)
        beak = all[i].pos + di
        plot!([beak.x, all[i].pos.x], [beak.y, all[i].pos.y], lw=3, legend=false)
    end
end

function ui(all::Vector{Boid})
    anim = @animate for k in 1:1000
        for i in 1:length(all)
            boid=all[i]

            speed, acceleration = rules(boid,all)
            speed = speedcheck(speed)
            
            position = boid.pos + speed
            
            all[i]=Boid(position, speed, acceleration, boid.viewarea)
        end

        redraw(all)
    end
    gif(anim, "anim.gif", fps=15)

    return all
end

n=10
rv=50
v0=10

world = Boid[]
for i in 1:n
    bi = Boid(Vec2(1.1*rand(11:255,1)[1],1.1*rand(11:255,1)[1]),Vec2(v0,v0),Vec2(0,0),rv)
    push!(world, bi)
end

world = ui(world)