close all
clear all
pkg load image

im = imread('./Imagens/microalgas (163).jpg');
figure('Name', 'imagem original')
imshow(im)
im = im(:,:,3);

for i=3:size(im,1) - 2
  for j=3:size(im,2) - 2
    px = im(i-2:i+2,j-2:j+2);
    imBlur(i,j) = uint8(sum(sum(px))/25);
  endfor
endfor
px
imBlur = im2bw(imBlur);
figure('Name', 'antes da erosão')
imshow(imBlur)

imErodida = imBlur;

EE = [1 1 1;
      1 1 1;
      1 1 1];

for i=2:size(imBlur,1)-1
  for j=2:size(imBlur,2)-1
    if(imBlur(i,j)==0)
      px = imBlur(i-1:i+1, j-1:j+1);
      if(sum(sum(px==EE))!=9)
        imErodida(i-1:i+1,j-1:j+1) = 0;
      endif
    endif
  endfor
endfor

figure('Name', 'depois da erosão')
imshow(imErodida)

for i=2:size(imErodida,1)-1
  for j=2:size(imErodida,2)-1
    if(imErodida(i,j)==0)
      px = imErodida(i-1:i+1, j-1:j+1);
      if(sum(sum(px==EE))!=9)
        imDilatada(i,j) = 1;
      endif
    endif
  endfor
endfor

figure('Name', 'imagem dilatada')
imshow(imDilatada)

imBW = imDilatada;

imRotulada = uint16(imBW);
novoRotulo = 20;
linha = 1;
for(i=2:size(imBW,1))
  for(j=2:size(imBW,2))
    if(imBW(i,j)==1)
      if((imBW(i-1,j) == 0)&&(imBW(i,j-1) == 0))
        imRotulada(i,j) = novoRotulo;
        novoRotulo++
      else
        if(((imBW(i-1,j) == 1)&&(imBW(i,j-1) == 0)) || ((imBW(i-1,j) == 0)&&(imBW(i,j-1) == 1)))
          if(imBW(i-1,j) == 1)
            imRotulada(i,j) = imRotulada(i-1,j);
          else
            imRotulada(i,j) = imRotulada(i,j-1);
          endif
        else
          if(((imBW(i-1,j) == 1)&&(imBW(i,j-1) == 1)) && ((imRotulada(i-1,j) == imRotulada(i,j-1))))
            imRotulada(i,j) = imRotulada(i-1,j);
          else
            %problemas
            imRotulada(i,j) = imRotulada(i-1,j);
            %armazenar o erro de rotula��o para posterior corre��o
             erros(linha, 1) = imRotulada(i-1,j);
             erros(linha, 2) = imRotulada(i,j-1);
             linha++;
          endif
        endif
      endif
    endif
  endfor
endfor
figure('Name','Imagem com erros de rotulacao')
imshow(imRotulada, [min(min(imRotulada)) max(max(imRotulada))])

errosCopia = erros;
if(erros(1,1)>erros(1,2))
  errosCopia(:,1) = erros(:,2);
  errosCopia(:,2) = erros(:,1);
endif

erros = sort(errosCopia,1); %ordena a matris de erros pela 1a coluna em ordem ascendente
errosCopia = erros;

for(k1=1:size(erros,1)) %para cada par de erros (valorEsq, valorDir) da matriz erros

  if(erros(k1,1)!=0) %se o erro ainda n�o foi verificado na imagem
    valorEsq = erros(k1,1);
    valorDir = erros(k1,2);

    % procurando as ocorr�ncias de valorEsq na imagem e substituindo por valorDir
    for(i=1:size(imRotulada,1))
      for(j=1:size(imRotulada,2))
        if(imRotulada(i,j)==valorEsq)
          imRotulada(i,j) = valorDir;
        endif
      endfor
    endfor

    %apagar as ocorr�ncias de valorEsq e valorDir, j� verificados, da matriz de erros
    for(k2=1:size(erros,1))
      if((erros(k2,1)==valorEsq) && (erros(k2,2)==valorDir))
        erros(k2,1)=0;
        erros(k2,2)=0;
        k1++;
      endif
    endfor

  endif

endfor

figure('Name','Imagem SEM erros de rotulacao')
imshow(imRotulada, [min(min(imRotulada)) max(max(imRotulada))])

qtdObjetos = size(unique(imRotulada),1)-1












