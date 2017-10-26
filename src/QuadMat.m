%% Main function, describes the global variables and does the simulation
function ExecMain
    clear all;
    clc;
    SetGlobals();
    global divisoes;
    %{
        A fun��o ode45 aceita como primeiro par�metro as derivadas do espa�o
        de estados, como segundo o tempo de simula��o e o terceiro � um array
        com as condi��es iniciais do sistema.
    %}
    [t,X] = ode45(@Quadcopter,0:0.001:10,[0 0 0 0 0 0 0 0 0 0 0 0]);
    cacm = zeros(divisoes,divisoes);
    %{
    	for k=1:length(t)
            x1 = X(k,3)
            x2 = X(k,4)
            [i,j] = AchaCelula(x1,x2);
            cacm(i,j) = cacm(i,j) + 1;
        end
    %}
    % comet3(X(:,11),X(:,9),X(:,7)); % Plot de X, Y, Z
    % comet3(X(:,1),X(:,3),X(:,5)); % Plot dos �ngulos
    % grid on
    % title('Posicao Drone','Interpreter','Latex')
    % ylabel('y','Interpreter','Latex')
    % xlabel('x','Interpreter','Latex')
    % zlabel('z','Interpreter','Latex')
     % plot(t,X(:,7)) % Posicao do pendulo
     %plot1(cacm);
     PlotDrone(t,X,0) % Plot dos �ngulos
     PlotDrone(t,X,1) % Plot do XYZ
end

%% SetGlobals: function description
function SetGlobals()
    % Aqui s�o definidas as vari�veis globais do sistema
    global divisoes x1ini x1fim x1divs x2ini x2fim x2divs x1delta x2delta numCores CodigoCores;
    numCores = 85;
    CodigoCores = zeros(numCores,3); % cores RGB
    for n=1:numCores
        CodigoCores(n,1) = 255 - 255*3*((n-1)/255); 
        CodigoCores(n,2) = 255 - 255*3*((n-1)/255); 
        CodigoCores(n,3) = 255 - 255*3*((n-1)/255); 
    end
    divisoes=60;
    x1ini=0; x1fim=1; x1divs=divisoes;
    x2ini=-4; x2fim=4;  x2divs=divisoes;
    x1delta=(x1fim-x1ini)/(x1divs);
    x2delta=(x2fim-x2ini)/(x2divs);
    %{    
    fprintf('\n\nValores do estado x1:\n');
    for n=1:divisoes
        fprintf('[%g] = %g a %g\n',n,x1ini+(n-1)*x1delta,x1ini+n*x1delta);
    end
    fprintf('\nValores do estado x2:\n');
    for n=1:divisoes
        fprintf('[%g] = %g a %g\n',n,x2ini+(n-1)*x2delta,x2ini+n*x2delta);
    end
    %}
    
    % Ctes do modelo
    global g L Kf Km m a b;
    g = - 9.81;       % Gravidade
    Ix = 5e-3;      % In�rcia eixo X
    Iy = 5e-3;      % In�rcia eixo Y
    Iz = 10e-3;     % In�rcia eixo Z
    L = 0.25;       % Dist�ncia do centro at� qualquer um dos motores
    Km = 3e-6;      % Cte aerodin�mica (thrust)
    Kf = 1e-7;      % Cte de arrasto (drag)
    m = 0.5;        % Massa do drone
    Jr = 6e-5;      % In�rcia do rotor
    % Redu��o de vari�veis
    a(1) = (Iy - Iz)/Ix;
    a(2) = Jr/Ix;
    a(3) = (Iz - Ix)/Iy;
    a(4) = Jr/Iy;
    a(5) = (Ix - Iy)/Iz;
    b(1) = L/Ix;
    b(2) = L/Iy;
    b(3) = L/Iz;
end