using Plots

@userplot CirclePlot
@recipe function f(cp::CirclePlot)
    x, y, i = cp.args
    # n = length(x)
    inds = circshift(1:n, 1 - 1)
    markershape --> :circle
    # linewidth --> 3
    # seriesalpha --> range(0, 1, length = n)
    # aspect_ratio --> 1
    label --> false
    x[inds], y[inds]
end

n = 150
t = range(0, length=n);
x = t;
y = x*5;

anim = @animate for i ∈ 1:n
    circleplot(x, y, i)
    xlims!(0,n)
    ylims!(0,n)
end
gif(anim, "anim_fps15.gif", fps = 15)

# mutable struct Vrs
#     x::Int64
#     y::Int64

#     function Vrs()
#         x=0;
#         y=0;

#         new(x,y);
#     end
# end

# function moving(i::Int64,v::Vars)
#     xi=v.x+i;
#     yi=v.y+i;

#     v.x=xi;
#     v.y=yi;
#     return xi, yi
# end

# n=150
# anim = @animate for i ∈ 1:n
#     xi,yi=moving(i,Vars)
#     plot(xi, yi, seriestype = :scatter)
#     plot!(xlims=[0, n])
#     plot!(ylims=[0,n])
# end
# gif(anim, "anim_fps15.gif", fps = 15)
