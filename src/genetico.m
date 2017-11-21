%% Genetico: Aplica��o de AG para os ganhos do PID
function [gainsOut, fitOut] = Genetico(Target,SetPoint)
    global Individuos NumGenes SelectedInd Pai1 Pai2 Filhos1 Filhos2 Filhos3 FitnessPai FitnessFilhos3 FitnessFilhos1 FitnessFilhos2;
    % Defini��o das constantes
    Geracoes = 60; % 
    Individuos = 14; %
    NumGenes = 3; % Kp Kd e Ki
    % Iniciando os arrays para as informa��es do gen�tico
    OldFit = zeros(Geracoes,Individuos);
    FitnessIn = zeros(1,Individuos);
    Gains = zeros(Geracoes,Individuos,NumGenes);
    Selected = zeros(Geracoes,Individuos,NumGenes);
    SelectedInd = Individuos/2;
    Pai1 = zeros(SelectedInd,NumGenes);
    Pai2 = zeros(SelectedInd,NumGenes);
    Filhos1 = zeros(SelectedInd,NumGenes);
    Filhos2 = zeros(SelectedInd,NumGenes);
    Filhos3 = zeros(SelectedInd,NumGenes);
    FitnessPai = zeros(SelectedInd);
    FitnessFilhos1 = zeros(SelectedInd);
    FitnessFilhos2 = zeros(SelectedInd);
    FitnessFilhos3 = zeros(SelectedInd);
    % Para cada gera��o
    for G = 1:Geracoes
        disp(['Entrando na Gera��o: ',num2str(G)])
        % Se for a primeira tem que calcular o fitness e gerar rand�mico os valores dos genes
        if (G == 1)
            for I = 1:Individuos
                Gains(G,I,1) = 8*rand(); % Kp
                Gains(G,I,2) = 8*rand(); % Ki
                Gains(G,I,3) = 8*rand(); % Kd
                disp(['Calculando Fitness do individuo: ',num2str(I)])
                FitnessIn(1,I) =  Fitness(Target,Gains(1,I,:),SetPoint);
                disp(['Valor do Fitness do individuo: ',num2str(FitnessIn(I))])
            end
        else
            % Caso contr�rio pega o retorno da fun��o de sele��o
            Gains(G,:,:) =  Selected(G-1,:,:);
            FitnessIn(1,:) = OldFit(G-1,:); 
            Gains(G,1,:)
        end
        % Faz a sele��o, crossover, muta��o e etc
        [Selected(G,:,:), OldFit(G,:)] = Select(Gains(G,:,:),SetPoint,Target,FitnessIn(1,:));
        % Selected
        if (G == Geracoes)
            Selected(G,1,:)
            OldFit(G,1)
            Fitness(Target, Selected(G,1,:) , SetPoint, 1);
        end
    end
    figure()
    plot(1:1:Geracoes, OldFit(:,1)) % Melhor fitness por gera��o
    title('Evolu\c{c}\~{a}o do Fitness','Interpreter','Latex')
    ylabel('Fitness','Interpreter','Latex')
    xlabel('Gera\c{c}\~{a}o','Interpreter','Latex')
    grid on
end

%% Select: Seleciona os melhores, faz crossover e muta��o, seleciona novamente e retorna
function [Selected, OldFit] = Select(Gains,SetPoint,Target,FitnessIn)
    % Instancia��o das vari�veis globais
    global Individuos NumGenes SelectedInd Pai1 Pai2 Filhos1 Filhos2 Filhos3 FitnessPai FitnessFilhos3 FitnessFilhos1 FitnessFilhos2;
    % Define as vari�veis de sa�da
    Selected = zeros(1,Individuos,NumGenes);
    OldFit = zeros(1,Individuos);
    % Fazendo a primeira sele��o (somente os pais com o melhor fitness que continuam) 
    [BestFitIn,OldIdxIn] = sort(FitnessIn,'descend');
    % Crossover usando os melhores pais
    for C = 1:SelectedInd
        % Um pai random e outro segue o for
        Pai1(C,:) = Gains(1,round((SelectedInd - 1)*(rand())) + 1,:);
        Pai2(C,:) = Gains(1,OldIdxIn(C),:);
        % S� realocando o fitness
        FitnessPai(C) = BestFitIn(C);
        % Um alpha rand�mico para o cross over
        Alpha = rand();
        % Um for para os genes (Kp, Ki, Kd)
        for NG = 1:NumGenes
            % Crossover e muta��o (para detalhes sobre a muta��o so verificar a fun��o)
            Filhos1(C,NG) = Mutation((1 - Alpha)*Pai1(C,NG) + Alpha*Pai2(C,NG));
            Filhos2(C,NG) = Mutation((1 - Alpha)*Pai2(C,NG) + Alpha*Pai1(C,NG));
            Filhos3(C,NG) = Mutation(Pai2(C,NG)/2 + Pai1(C,NG)/2);
        end
        % Calculo do fitness de cada filho
        disp(['Calculando Fitness do filho 1 para o individuo: ',num2str(OldIdxIn(C))])
        FitnessFilhos1(C) = Fitness(Target,Filhos1(C,:),SetPoint);
        disp(['Valor do Fitnees do filho: ',num2str(FitnessFilhos1(C))])
        disp(['Calculando Fitness do filho 2 para o individuo: ',num2str(OldIdxIn(C))])
        FitnessFilhos2(C) = Fitness(Target,Filhos2(C,:),SetPoint);
        disp(['Valor do Fitnees do filho: ',num2str(FitnessFilhos2(C))])
        disp(['Calculando Fitness do filho 3 para o individuo: ',num2str(OldIdxIn(C))])
        FitnessFilhos3(C) = Fitness(Target,Filhos3(C,:),SetPoint);
        disp(['Valor do Fitnees do filho: ',num2str(FitnessFilhos3(C))])
    end
    % Preparando os arrays para a segunda sele��o
    % Aqui se junta todos os individuos em um �nico array
    Population = cat(1,Pai2(:,:),Filhos1(:,:),Filhos2(:,:),Filhos3(:,:));
    % Aqui todos os fitness
    FitPop = cat(1,FitnessPai(:,1),FitnessFilhos1(:,1),FitnessFilhos2(:,1),FitnessFilhos3(:,1));
    % Tamannho do array
    PopSize = size(Population);
    % Segunda sele��o
    [BestFit,OldI] = sort(FitPop,'descend');
    % O for s� reorganiza as informa��es para serem retornadas pela fun��o
    for S = 1:(PopSize(1)/2)
        Selected(:,S,:) = Population(OldI(S),:);
        OldFit(:,S) = BestFit(S);
    end
end

%% Mutation: Realiza a muta��o
function [NewVal] = Mutation(OldVal)
    % Chance de ocorrer muta��o (Ex: 0.15 -> 15%)
    Chance = 0.15;
    if (rand < Chance)
        % Caso ocorra muta��o faz uma soma ou subtra��o de 0 a 100% do valor original
        NewVal = abs(OldVal  + (0.4*rand() - 0.2)*OldVal);
    else
        NewVal = OldVal;
    end
    if (NewVal >= 15)
        NewVal = 12 + rand();
    end
end
