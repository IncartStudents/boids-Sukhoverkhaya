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

function norm(v::Vec2)
    n=sqrt(v.x^2+v.y^2)
    return n
end

va=Vec2(6,8)
vb=Vec2(3.3,4.4)
norm(va)

mutable struct Boid
    pos::Vec2
    speed::Vec2
    acceleration::Vec2
    viewarea::Float64
end

# n=10
# world=fill(Boid(Vec2(0,0),Vec2(0,0),Vec2(0,0),0.0),n)

# world[5]=Boid(Vec2(1,2),Vec2(3,4),Vec2(5,6))
# world[5].speed

# world[5]
# pos=world[5].pos; speed=world[5].speed; acc=world[5].acceleration
# pos+=Vec2(1,2); speed+=Vec2(1,2); acc+=Vec(1,2)
# world[5]=Boid(pos,speed,acc)
# world[4].speed=Vec2(5,6) ##!!!!!!!!!!!! работает сразу для всех строк
# world[4].speed

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

function where_hit(position::Vec2,borders1::Vec2,borders2::Vec2)
    xmin=borders1.x; ymin=borders1.y; xmax=borders2.x; ymax=borders2.y;
    result=0;

    if subj.y==ymax && x==xmax || y==ymin && x==xmax || y==ymax && x==xmin || y==ymin && x==xmin # попадание в угол
        result=1
    elseif y>=ymax || y<=ymin # упёрся в верхний или нижний край
        result=2
    elseif x>=xmax || x<=xmin # упёрся в правый или левый край
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

    speed=Vec2(dx,dy)
    return speed
end

function separation(x::Vector{Float64},y::Vector{Float64},rv::Float64,dx::Vector{Float64},dy::Vector{Float64})
    ax=fill(0.0,10);
    ay=fill(0.0,10);

    n=length(x);
    for i in 1:n
        dxi=[];
        dyi=[];
        k=0;
        for j in 1:n
            r=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2);
            if r<=rv && i!=j
                rx=x[i]-x[j];
                ry=y[i]-y[j];
                push!(dxi, rx)
                push!(dyi, ry)
                k=1;
            end
        end

        if k>0
            dxi_m=-1*sum(dxi);
            dyi_m=-1*sum(dyi);

            ax[i]=dx[i]-dxi_m;
            ay[i]=dy[i]-dyi_m;
            l=sqrt(ax[i]^2+ay[i]^2);
            ax[i]*=1/l;
            ay[i]*=1/l;
        end
    end

    return ax,ay
end

function cohesion(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},rv::Float64)
    ax=fill(0.0,10);
    ay=fill(0.0,10);
    
    n=length(x);
    for i in 1:n
        xi=[];
        yi=[];
        k=0;
        for j in 1:n
            r=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2);
            if r<=rv && i!=j
                push!(xi, x[j])
                push!(yi, y[j])
                k=1;
            end
        end

        if k>0
            xm=mean(xi);
            ym=mean(yi);
            rx=xm-x[i];
            ry=ym-y[i];

            l=sqrt(rx^2+ry^2);
            ax[i]=rx/l;
            ay[i]=ry/l;
        end
    end

    return ax,ay
end

function alignment(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},rv::Float64)
    ax=fill(0.0,10);
    ay=fill(0.0,10);
    
    n=length(x);
    for i in 1:n
        dxi=[];
        dyi=[];
        k=0;
        for j in 1:n
            r=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2);
            if r<=rv && i!=j
                push!(dxi, dx[j])
                push!(dyi, dy[j])
                k=1;
            end
        end

        if k>0
            ax[i]=sum(dxi)-dx[i];
            ay[i]=sum(dyi)-dy[i];
            ax[i]/=100;
            ay[i]/=100;
        end
    end

    return ax,ay
end

function speedcheck(dx::Vector{Float64},dy::Vector{Float64})
    n=length(dx);
    limit=10;
    for i in 1:n
        v=sqrt(dx[i]^2*dy[i]^2);
        if v>limit
            k=limit/v;
            dx[i]=dx[i]*k;
            dy[i]=dy[i]*k;
        end
    end

    return dx,dy
end

function rules(boid::Vector{Boid})
    position=boid.position; speed=boid.speed; acceleration=boid.acceleration; viewarea=boid.viewarea
    
    acc_cohesion=Vec2(0,0); acc_separation=Vec2(0,0); acc_alignment=Vec2(0,0); acc_res=Vec2(0,0)

    acc_cohesion=cohesion(position,speed,viewarea)
    acc_separation=separation(position,speed,viewarea)
    acc_alignment=alignment(position,speed,viewarea)

    acc_res=acc_cohesion+acc_separation+acc_alignment
    speed_res=speed+acc_res

    speed_res=rebound(position,speed_res)

    return speed_res,acc_res
end

function redraw(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64})
    x=x+dx;
    y=y+dy;
    # scatter(x, y, markershape = :utriangle, ms=5, lab="", xlim=(0,300), ylim=(0,300))
    scatter(x, y, markershape = :circle, ms=5, lab="", xlim=(0,300), ylim=(0,300))
    n=length(x)
    for i in 1:n
        l=5
        lr=sqrt(dx[i]^2+dy[i]^2)
        k=l/lr
        dxi=dx[i]*k
        dyi=dy[i]*k
        x1=[x[i],x[i]+dxi]
        y1=[y[i],y[i]+dyi]
        plot!(x1,y1, lw=3, legend=false)
    end
    return x,y
end

function ui(v::Vector{Boid})
    anim = @animate for k in 1:1000
        for i in 1:length(v)
            boid=v[i];

            speed,acceleration=rules(boid)
            speed=speedcheck(speed)
            position=redraw()
            
            v[i]=Boid(position,speed,acceleration,viewarea=boid.viewarea)
        end
    end
    gif(anim, "anim.gif", fps=15)
end

ui(world)