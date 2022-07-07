using CImGui
using ImPlot
import CImGui: ImVec2
using CImGui.CSyntax.CStatic
using Statistics

include(joinpath(pathof(ImPlot), "..", "..", "demo", "Renderer.jl"))
using .Renderer

# function ui()
#     CImGui.Begin("Boids")
#     ImPlot.SetNextPlotLimits(0, 30, 0, 30)
#     if ImPlot.BeginPlot("", C_NULL, C_NULL, ImVec2(900,900), flags=ImPlot.ImPlotAxisFlags_NoGridLines, x_flags = ImPlotAxisFlags_NoDecorations, y_flags = ImPlotAxisFlags_NoDecorations)
#         ImPlot.SetNextMarkerStyle(ImPlotMarker_Up)
#         ImPlot.PlotScatter([5,10,20], [5,10,20])
#     end
#     CImGui.End()
# end

# function show_gui()
#     # state = Vars()
#     Renderer.render(
#         # ()->ui(state), 
#         ()->ui(), 
#         width = 1360, 
#         height = 950, 
#         title = "", 
#         hotloading = true
#     )
#     # return state
# end

# show_gui()

mutable struct Vars
    x::Vector{Int64}
    y::Vector{Int64}
    k::Vector{Int64}
    xdir::Vector{Int64}
    # ydir::Vector{Int64}
    b::Vector{Int64}
    cansee::Vector{Bool}
    time::Float64


    function Vars()
        x=rand(11:30,10);
        k=rand(1:5,10);
        xdir=fill(1,10);
        b=fill(0,10);
        cansee=fill(0,10);
        time=0;
        y=k.*x.+b;
        # ydir=[0];

        new(x, y, k, xdir, b, cansee, time)
    end
end

# function first(v::Vars)
#     v.x=rand(11:30,10);
#     v.k=rand(1:5,10);
#     v.xdir=fill(1,10);   # 1 - вправо, -1 - влево
#     v.b=fill(0,10)
#     v.cansee=fill(0,10); # 1 - видит, 0 - не видит

#     v.k[1]=1;
#     v.b[1]=0;

#     v.y=v.k.*v.x.+v.b;
# end

# first(Vars())

function ui(v::Vars)



#     xmin=10;
#     ymin=10;
#     xmax=250;
#     ymax=250;
    
#     #ОТТАЛКИВАНИЕ ОТ ГРАНИЦ ПОЛЯ (первостепенно)
#     n=length(v.x);
#     for j in 1:n
#         if v.xdir[j]==1 # если двигался вправо
#             # попадание в угол
#             if v.y[j]>=ymax && v.x[j]>=xmax
#                 v.xdir[j]=-1;
#             elseif v.y[j]<=ymin && v.x[j]>=xmax
#                 v.xdir[j]=-1;
#             elseif v.y[j]>=ymax # упёрся в верхний край
#                 v.k[j]=-1*v.k[j];
#                 v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
#             elseif v.x[j]>=xmax # упёрся в правый край
#                 if v.k[j]<0     # двигался вниз
#                     v.xdir[j]=-1;
#                     v.k[j]=-1*v.k[j];
#                     v.b[j]=v.b[j]-(v.b[j]-v.y[j])*2;
#                 else # двигался вверх
#                     v.xdir[j]=-1;
#                     v.k[j]=-1*v.k[j];
#                     v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
#                 end
#             elseif v.y[j]<=ymin # упёрся в нижний край
#                 v.k[j]=-1*v.k[j];
#                 v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
#             end
#         else # если двигался влево
#             # попадание в угол
#             if v.y[j]<=xmin && v.x[j]<=ymin
#                 v.xdir[j]=1;
#             elseif v.y[j]>=ymax && v.x[j]<=xmin
#                 v.xdir[j]=1;
#             elseif v.y[j]>=ymax # упёрся в верхний край
#                 v.k[j]=-1*v.k[j];
#                 v.b[j]=v.b[j]-(v.b[j]-v.y[j])*2;
#             elseif v.x[j]<=xmin # упёрся в левый край
#                 if v.k[j]>0     # двигался вниз
#                     v.xdir[j]=1;
#                     v.k[j]=-1*v.k[j];
#                     v.b[j]=v.b[j]-(v.y[j]-v.b[j])*2;
#                 else # двигался вверх
#                     v.xdir[j]=1;
#                     v.k[j]=-1*v.k[j];
#                     v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
#                 end
#             elseif v.y[j]<=ymin # упёрся в нижний край
#                 v.k[j]=-1*v.k[j];
#                 v.b[j]=v.b[j]+(v.y[j]-v.b[j])*2;
#             end
#         end

#         if v.xdir[j]==-1
#             v.x[j]=Int64(round(CImGui.GetTime()*50));
#         else
#             v.x[j]=Int64(round(CImGui.GetTime()*50));
#         end
#     end
    
#     v.y=v.k.*v.x.+v.b;
#     ##################################################
    
#     r=10; # Радиус видимости каждой птички
#     for j in 1:n
#         for g in 1:n
#             l=sqrt((v.x[j]-v.x[g])^2+(v.y[j]-v.y[g])^2); # расстояние между птичками
#             if l<=r && l>0   # птичка попадает в радиус видимости
#                 # v.cansee[g]=1;
#                 # v.k[j]=(v.x[j]-v.x[g])/(v.y[j]-v.y[g]);
#                 # v.b[j]=v.y[j]-v.k[j]*v.x[j];
#                 v.xdir[j]=-1*v.xdir[j];
#             end
#         end
#     end

#     # SEPARATION

# # чек пакет маки или имгуи + обмен данными сокетами с алексеем или динамическая функция

#     ###################################################
    x=rand(11:290,5);
    y=rand(11:290,5);
#     # scatter(v.x, v.y, markershape = :utriangle, ms=3, lab="", xlim=(xmin-10,xmax+10), ylim=(xmin-10, ymax+10))
    
    CImGui.Begin("Boids")
    ImPlot.SetNextPlotLimits(0, 300, 0, 300)
    if ImPlot.BeginPlot("", C_NULL, C_NULL, ImVec2(900,900), flags=ImPlot.ImPlotAxisFlags_NoGridLines, x_flags = ImPlotAxisFlags_NoDecorations, y_flags = ImPlotAxisFlags_NoDecorations)
        ImPlot.SetNextMarkerStyle(ImPlotMarker_Up)
        ImPlot.PlotScatter(x,y)
    end

    CImGui.End()
end

function show_gui()
    state = Vars()
    Renderer.render(
        ()->ui(state), 
        width = 1360, 
        height = 950, 
        title = "", 
        hotloading = true
    )
    return state
end

show_gui()
