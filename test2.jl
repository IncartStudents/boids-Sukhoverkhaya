using Plots 

# @gif for i in 1:50
#     plot(i,i*5)
# end

mutable struct Vars
    x::Vector{Int64}
    y::Vector{Int64}
    k::Vector{Int64}
    xdir::Vector{Int64}
    # ydir::Vector{Int64}
    b::Vector{Int64}


    function Vars()
        x=[0];
        y=[0];
        k=[0];
        xdir=[0];
        b=[];
        # ydir=[0];

        new(x, y, k, xdir, b)
    end
end

function ui(v::Vars)

v.x=rand(10:20,10);
v.k=rand(1:5,10);
v.xdir=fill(1,10);   # 1 - вправо, -1 - влево
# v.ydir=fill(1,10);   # 1 - вверх, -1 - вниз
v.b=fill(0,10)

v.k[1]=1;
v.b[1]=0;

v.y=v.k.*v.x.+v.b;

anim = @animate for i in 1:1000
    xmin=10;
    ymin=10;
    xmax=250;
    ymax=250;

    n=length(v.x);
    for j in 1:n
        if v.xdir[j]==1 # если двигался вправо
            # попадание в угол
            if v.y[j]>=ymax && v.x[j]>=xmax
                v.xdir[j]=-1;
            elseif v.y[j]<=ymin && v.x[j]>=xmax
                v.xdir[j]=-1;
            elseif v.y[j]>=ymax # упёрся в верхний край
                v.k[j]=-1*v.k[j];
                v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
            elseif v.x[j]>=xmax # упёрся в правый край
                if v.k[j]<0     # двигался вниз
                    v.xdir[j]=-1;
                    v.k[j]=-1*v.k[j];
                    v.b[j]=v.b[j]-(v.b[j]-v.y[j])*2;
                else # двигался вверх
                    v.xdir[j]=-1;
                    v.k[j]=-1*v.k[j];
                    v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
                end
            elseif v.y[j]<=ymin # упёрся в нижний край
                v.k[j]=-1*v.k[j];
                v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
            end
        else # если двигался влево
            # попадание в угол
            if v.y[j]<=xmin && v.x[j]<=ymin
                v.xdir[j]=1;
            elseif v.y[j]>=ymax && v.x[j]<=xmin
                v.xdir[j]=1;
            elseif v.y[j]>=ymax # упёрся в верхний край
                v.k[j]=-1*v.k[j];
                v.b[j]=v.b[j]-(v.b[j]-v.y[j])*2;
            elseif v.x[j]<=xmin # упёрся в левый край
                if v.k[j]<0     # двигался вниз
                    v.xdir[j]=1;
                    v.k[j]=-1*v.k[j];
                    v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
                else # двигался вверх
                    v.xdir[j]=1;
                    v.k[j]=-1*v.k[j];
                    v.b[j]=v.b[j]-(v.y[j]-v.b[j])*2;
                end
            elseif v.y[j]<=ymin # упёрся в нижний край
                v.k[j]=-1*v.k[j];
                v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
            end
        end
        
        # # попадание в угол
        # if v.y[j]==ymax && v.x[j]==xmax
        #     v.xdir[j]=-1;
        # elseif v.y[j]==0 && v.x[j]==xmax
        #     v.xdir[j]=-1;
        # elseif v.y[j]==0 && v.x[j]==0
        #     v.xdir[j]=1;
        # elseif v.y[j]==ymax && v.x[j]==0
        #     v.xdir[j]=1;
        # end

        if v.xdir[j]==-1
            v.x[j]=v.x[j]-1;
        else
            v.x[j]=v.x[j]+1;
        end
    end
    
    v.y=v.k.*v.x.+v.b;
    scatter(v.x, v.y, markershape = :utriangle, ms=3, lab="", xlim=(xmin-10,xmax+10), ylim=(xmin-10, ymax+10))
end

gif(anim, fps=15)

end

ui(Vars())