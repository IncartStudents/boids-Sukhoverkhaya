using Plots 
using Statistics

mutable struct Vars
    x::Vector{Float64}
    y::Vector{Float64}
    dx::Vector{Float64}
    dy::Vector{Float64}
    kv::Vector{Float64}

    function Vars()
        x=rand(11:250,10);
        y=rand(11:250,10);
        dx=fill(1,10);
        dy=fill(1,10);
        kv=fill(1,10);

        new(x, y, dx, dy, kv)
    end
end

function rebound(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64})
    xmin=10;
    xmax=290;
    ymin=10;
    ymax=290;
    
    n=length(x);
    for i in 1:n
        if dx[i]>0 # если двигался вправо
            # попадание в угол
            if y[i]>=ymax && x[i]>=xmax
                dx[i]=-1*dx[i];
                dy[i]=-1*dy[i];
            elseif y[i]<=ymin && x[i]>=xmax
                dx[i]=-1*dx[i];
                dy[i]=-1*dy[i];
            elseif y[i]>=ymax # упёрся в верхний край
                dy[i]=-1*dy[i];
            elseif x[i]>=xmax # упёрся в правый край
                dx[i]=-1*dx[i];
            elseif y[i]<=ymin # упёрся в нижний край
                dy[i]=-1*dy[i];
            end
        else # если двигался влево
            # попадание в угол
            if y[i]<=ymin && x[i]<=xmin
                dx[i]=-1*dx[i];
                dy[i]=-1*dy[i];
            elseif y[i]>=ymax && x[i]<=xmin
                dx[i]=-1*dx[i];
                dy[i]=-1*dy[i];
            elseif y[i]>=ymax # упёрся в верхний край
                dy[i]=-1*dy[i];
            elseif x[i]<=xmin # упёрся в левый край
                dx[i]=-1*dx[i];
            elseif y[i]<=ymin # упёрся в нижний край
                dy[i]=-1*dy[i];
            end
        end
    end
    return dx,dy
end

function rooles(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},kv::Vector{Float64})
    ###########################################3
    rv=10;
    n=length(x);
    for i in 1:n
        xi::Vector{Float64}=[];
        yi::Vector{Float64}=[];
        w=0;
        # xi=[];
        # yi=[];
        for j in 1:n
            r=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2);
            if r<rv && r>0
                push!(xi, x[j]);
                push!(yi, y[j]);
                w=w+1;
            end
        end

        if w>0
            mx=mean(xi);    # координаты центра масс
            my=mean(yi);

            dx[i],dy[i],kv[i]=separation(x[i],y[i],mx,my)
        else
            kv[i]=1;
        end

    end
    #######################
    rv=80;
    n=length(x);
    for i in 1:n
        xi::Vector{Float64}=[];
        yi::Vector{Float64}=[];
        w=0;
        # xi=[];
        # yi=[];
        for j in 1:n
            r=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2);
            if r<rv && r>0
                push!(xi, x[j]);
                push!(yi, y[j]);
                w=w+1;
            end
        end

        if w>0
            mx=mean(xi);    # координаты центра масс
            my=mean(yi);

            dx[i],dy[i],kv[i]=coheretion(x[i],y[i],mx,my,dx[i],dy[i])
        else
            kv[i]=1;
        end
    end
    #######################
    return dx,dy,kv
end

function separation(x::Float64,y::Float64,mx::Float64,my::Float64)
    dx=x-mx;
    dy=y-my;
    d=sqrt(dx^2+dy^2);
    kv=10/d;
    # f=dx/d;
    # dx=d;
    # dy=dy/f;
    # dx=dx*(1/d);
    # dy=dy*(1/d);
    return dx,dy,kv
end

function coheretion(x::Float64,y::Float64,mx::Float64,my::Float64,dx::Float64,dy::Float64)
    nx=mx-x;
    ny=my-y;
    dx=dx+nx/10;
    dy=dy+ny/10;
    d=sqrt(dx^2+dy^2);
    kv=5/d;
    # f=dx/d;
    # dx=d;
    # dy=dy/f;
    # dx=dx*(1/d);
    # dy=dy*(1/d);
    return dx,dy,kv
end

function redraw(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},kv::Vector{Float64})
    x=x+kv.*dx;
    y=y+kv.*dy;
    scatter(x, y, markershape = :utriangle, ms=3, lab="", xlim=(0,300), ylim=(0,300))
    return x,y
end

function ui(v::Vars)

    anim = @animate for k in 1:1000
        v.dx,v.dy,v.kv=rooles(v.x,v.y,v.dx,v.dy,v.kv);
        v.dx,v.dy=rebound(v.x,v.y,v.dx,v.dy);
        v.x,v.y=redraw(v.x,v.y,v.dx,v.dy,v.kv);
    end

    gif(anim, "anim.gif", fps=15)
end

ui(Vars())