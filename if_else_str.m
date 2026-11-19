function str = if_else_str(cond, a, b)
% cond なら a、そうでなければ b
if cond
    str = a;
else
    str = b;
end
end
