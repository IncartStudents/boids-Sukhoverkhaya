using Plots 
using Statistics

# @gif for i in 1:50
#     plot(i,i*5)
# end

mutable struct Vars
    x::Vector{Float64}
    y::Vector{Float64}
    k::Vector{Float64}
    xdir::Vector{Int64}
    # ydir::Vector{Int64}
    b::Vector{Float64}
    cansee::Vector{Bool}


    function Vars()
        x=[];
        y=[];
        k=[];
        xdir=[0];
        b=[];
        cansee=[];
        # ydir=[0];

        new(x, y, k, xdir, b, cansee)
    end
end

function ui(v::Vars)

v.x=rand(11:60,10);
v.k=rand(1:5,10);
v.xdir=fill(1,10);   # 1 - вправо, -1 - влево
v.b=fill(0,10)
v.cansee=fill(0,10); # 1 - видит, 0 - не видит

v.k[1]=1;
v.b[1]=0;

v.y=v.k.*v.x.+v.b;

anim = @animate for i in 1:1000
    xmin=10;
    ymin=10;
    xmax=250;
    ymax=250;
    
    # ОТТАЛКИВАНИЕ ОТ ГРАНИЦ ПОЛЯ (первостепенно)
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
            if v.y[j]<=ymin && v.x[j]<=xmin
                v.xdir[j]=1;
            elseif v.y[j]>=ymax && v.x[j]<=xmin
                v.xdir[j]=1;
            elseif v.y[j]>=ymax # упёрся в верхний край
                v.k[j]=-1*v.k[j];
                v.b[j]=v.b[j]-(v.b[j]-v.y[j])*2;
            elseif v.x[j]<=xmin # упёрся в левый край
                if v.k[j]>0     # двигался вниз
                    v.xdir[j]=1;
                    v.k[j]=-1*v.k[j];
                    v.b[j]=v.b[j]-(v.y[j]-v.b[j])*2;
                else # двигался вверх
                    v.xdir[j]=1;
                    v.k[j]=-1*v.k[j];
                    v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
                end
            elseif v.y[j]<=ymin # упёрся в нижний край
                v.k[j]=-1*v.k[j];
                v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
            end
        end
        ###############33

        r=50; # Радиус видимости каждой птички
        # for j in 1:n
            v.cansee=fill(0,10);
            xi=[];
            yi=[];
            k=0;
            for g in 1:n
                l=sqrt((v.x[j]-v.x[g])^2+(v.y[j]-v.y[g])^2); # расстояние между птичками
                if l<=r && l>0   # птичка попадает в радиус видимости
                    v.cansee[g]=1;
                    push!(xi, v.x[g])
                    push!(yi, v.y[g])
                    k=k+1;
                    # v.k[j]=(v.x[j]-v.x[g])/(v.y[j]-v.y[g]);
                    # v.b[j]=v.y[j]-v.k[j]*v.x[j];
                    # v.xdir[j]=-1*v.xdir[j];
                    # v.k[j]=-1*v.k[j];
                    # v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
                    
                end
            end
            

            if k>0
                mx=mean(xi);
                my=mean(yi);

                # v.k[j]=(v.x[j]-mx)/(v.y[j]-my);
                # v.b[j]=v.y[j]-v.k[j]*v.x[j];
                # v.xdir[j]=-1*v.xdir[j];
            end

        # end

        if v.xdir[j]==-1
            v.x[j]=v.x[j]-1;
        else
            v.x[j]=v.x[j]+1;
        end
    end
    ###################################################
    

    # SEPARATION

# чек пакет маки или имгуи + обмен данными сокетами с алексеем или динамическая функция

    ###################################################
    
    v.y=v.k.*v.x.+v.b;
    scatter(v.x, v.y, markershape = :utriangle, ms=3, lab="", xlim=(xmin-10,xmax+10), ylim=(xmin-10, ymax+10))
end

gif(anim, "anim.gif", fps=15)

end

ui(Vars())