%% ABRINDO AS IMAGENS
clear
clc

load('dados.mat')

heigth = 160;
width = 120;

inicio = 59;
fim = 310;%321
trainPic = (fim-inicio)+1;

reduz = 1/8;

%pasta = 'C:\Users\Gilmar Correia\Documents\Documentos\Projetos\GitHub\RNA-OpenCV\Licoes\LaplacianFilter\';
pasta = '/Users/junior/Desktop/GitHub/RNA-OpenCV/Licoes/LaplacianFilter/';
tipo = 'BCGL';

ANNimagens = zeros(width*reduz,heigth*reduz,1,trainPic);
ANNlabels = zeros(trainPic,3);
ANNvalidations = zeros(trainPic,3);
ANNresult = zeros(trainPic,4);

j=1;
for i = inicio:fim 
    F=fft2(imread(strcat(pasta,tipo,int2str(i),'.jpg')));
    ANNimagens(:,:,j) = imresize(fftshift(log(abs(F))),reduz);
    ANNlabels(j,:) = dados(i+1,:);
    j = j+1;
end

ANNimagens = reshape(ANNimagens,width*reduz*heigth*reduz,trainPic);
ANNlabels = ANNlabels';

save('ANNlabels.mat','ANNlabels');
save('ANNimagens.mat','ANNimagens');
%% TREINANDO A REDE

for hiddenNeurons = 1:35
    netR=feedforwardnet(hiddenNeurons);
    netR.trainParam.max_fail = 100;

    %load('netR.mat');
    
    netR=train(netR,ANNimagens,ANNlabels);

    %save('netR','netR');

    %testePic = ANNimagens(:,1)';
    %save('testePic.mat','testePic');
    %% VALIDA??O
    j=1;
    for i = inicio:fim
        ANNresult(j,:) = [i sim(netR,ANNimagens(:,j))'];
        j=j+1;
    end

    for i=(fim+1):321
        A = double(imresize(fftshift(log(abs(fft2(imread(strcat(pasta,tipo,int2str(i),'.jpg')))))),reduz));
        A = reshape(A,width*reduz*heigth*reduz,1);
        ANNresult(j,:) = [i sim(netR,A)'];
        j=j+1;
    end

    ANNvalidations(hiddenNeurons,1) = hiddenNeurons;
    for i = inicio:321

        if ( sqrt( (((dados(i+1,1))-ANNresult(i-58,2)).^2)+ (((dados(i+1,2))-ANNresult(i-58,3)).^2) ) <= 10)
            ANNvalidations(hiddenNeurons,2) = ANNvalidations(hiddenNeurons,2) + 1;
        end
        
        if ((dados(i+1,3))-ANNresult(i-58,4) <= 10)
            ANNvalidations(hiddenNeurons,3) = ANNvalidations(hiddenNeurons,3) + 1;
        end
    end
end