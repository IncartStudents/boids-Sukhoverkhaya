using Plots 
using Statistics

mutable struct Vars
    x::Vector{Float64}
    y::Vector{Float64}
    dx::Vector{Float64}
    dy::Vector{Float64}
    rv::Float64
    vmin::Float64
    vmax::Float64

    function Vars()
        x=rand(11:250,10);
        y=rand(11:250,10);
        dx=fill(1,10);
        dy=fill(1,10);
        rv=50.0;
        vmin=sqrt(2);
        vmax=5;

        new(x, y, dx, dy, rv, vmin, vmax)
    end
end

# отскакивание от границ поля
function rebound(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64})
    xmin=10;
    xmax=290;
    ymin=10;
    ymax=290;
    
    n=length(x);
    for i in 1:n
            # проверка выхода за границы поля из-за выполнения правил
            if y[i]>ymax
                y[i]=ymax
            end
            if x[i]>xmax
                x[i]=xmax
            end
            if y[i]<ymin
                y[i]=ymin
            end
            if x[i]<xmin
                x[i]=xmin
            end

            if y[i]>=ymax && x[i]>=xmax || y[i]<=ymin && x[i]>=xmax || y[i]>=ymax && x[i]<=xmin || y[i]<=ymin && x[i]<=xmin # попадание в угол
                dx[i]=-1*dx[i];
                dy[i]=-1*dy[i];
            elseif y[i]>=ymax || y[i]<=ymin # упёрся в верхний или нижний край
                dy[i]=-1*dy[i];
            elseif x[i]>=xmax || x[i]<=xmin # упёрся в правый или левый край
                dx[i]=-1*dx[i];
            end
    end
    return dx,dy
end

function separation(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},rv::Float64)
    n=length(x);
    for i in 1:n
        for j in 1:n
            r=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2);
            if r<=rv && i!=j
                dx1=-1*(x[j]-x[i]);
                dy1=-1*(y[j]-y[i]);
                l=sqrt(dx1^2+dy1^2);
                dx[i]=dx[i]+dx1*(1/l);
                dy[i]=dy[i]+dy1*(1/l);
            end
        end
    end
    return dx,dy
end

function cohesion(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},rv::Float64)
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
            dx1=xm-x[i];
            dy1=ym-y[i];
            
            l=sqrt(dx1^2+dy1^2);
            dx[i]=dx[i]+dx1*(1/l);
            dy[i]=dy[i]+dy1*(1/l);
        end
    end

    return dx,dy
end

function alignment(x::Vector{Float64},y::Vector{Float64},dx::Vector{Float64},dy::Vector{Float64},rv::Float64)
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
            dx1=sum(dxi);
            dy1=sum(dyi);
            
            dx[i]=dx[i]+dx1;
            dy[i]=dy[i]+dy1;
        end
    end

    return dx,dy
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

function ui(v::Vars)

    anim = @animate for k in 1:1000
        v.dx,v.dy=cohesion(v.x,v.y,v.dx,v.dy,v.rv);
        v.dx,v.dy=separation(v.x,v.y,v.dx,v.dy,v.rv);
        # v.dx,v.dy=alignment(v.x,v.y,v.dx,v.dy,v.rv);
        v.dx,v.dy=rebound(v.x,v.y,v.dx,v.dy);
        v.dx,v.dy=speedcheck(v.dx,v.dy);
        v.x,v.y=redraw(v.x,v.y,v.dx,v.dy,);
    end

    gif(anim, "anim.gif", fps=15)
end

ui(Vars())