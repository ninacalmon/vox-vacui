extends Node2D

'''
1. OBJETIVO
1.1 O QUE PRECISO?:
	Um novo sistema de seleção para a nave, funcionando através de 'snapping' de 
	um objeto interativo para o outro.

1.2 POR QUE?:
	O sistema atual (point n click) não funciona bem com controles e demonstra
	fragilidades e bugs na implementação.

1.3 RESULTADO ESPERADO:
	Um novo sistema de seleção, utilizando 'snaps' que trocam horizontalmente
	através de setas nos cantos OU teclas de declado e controle.
	Esse snap deve alterar a posição e zoom da câmera, visando deixar BEM claro
	qual objeto está selecionado atualmente e habilitante a interação.

2. ESCOPO
2.1 INCLUÍDO:
	- Novo sistema de câmera com ajustes no zoom, posicionamento e transições.
	- Novo sistema de focus/unfocus.
	- Ajustes visuais como camera bobbing e outros efeitos visuais que visem deixar
	bem claro o objeto selecionado atualmente.
	- Novos controles (e ajustes no InputGuide).

2.2 NÃO INCLUÍDO:
	- (A NÃO SER QUE NECESSÁRIO) Mudanças relevantes no código atual de interação
	de cada objeto.


3. EXPERIÊNCIA
3.1 O QUE O JOGADOR FAZ?:
	- Dá o input (click nas flechas horizontais OU botões de teclado ou controle) caso queira
	trocar de objeto em foco.
	- Clica e interage com o objeto selecionado APENAS.

3.2 O QUE ACONTECE?:
	- Há um output visual de mudança de foco (zoom, posição de câmera, highlights).
	- A interação com o novo objeto é habilitada.
	- A interação com os demais objetos é DESabilitada.

4. REQUISITOS
4.1 FUNCIONALIDADES:
	- Sistema de foco com exclusividade de objeto.
	- Highlight e outros outputs que visem deixar BEM CLARO o objeto atual.
	- Sistema de câmeras com transições. Feito através do plugin PhantonCamera.
	- Novos controles e UI.
	- TALVEZ output quando o player tenta interagir om um objeto não focado atualmente (ex: camera shake)

4.2 RESTRIÇÕES:
	- Quando focado em um obejto, você poderá interagir APENAS COM ELE.
	- Durante a interação, não pode trocar o foco.

5. ARQUITETURA
5.1 SISTEMAS E RESPONSABILIDADES:
	- Nova classe 'Interactable' que será resposável por armazenar as informações comuns de
	cada objeto interagível -> camera, ativação de highlight, estado ocupado ou idle.
	- InteractableManager que escuta os inputs e dá os outputs, tem acesso aos Interactables,
	controla as câmeras através da phantom camera.
	- Novas câmeras para cada Interactable.

6. ETAPAS:
	1 - Desenvolvimento da classe 'Interactable'- EM ANDAMENTO
	2 - Desenvolvimento InteractableManager - FEITO
	3 - Câmeras - EM ANDAMENTO
	4 - Ajustar cada um dos objetos para funcionar com o sistema novo:
		4.1 - ResourcesMachine - FEITO
		4.2 - Monitor - FEITO
		4.3 - Porta saída - EM ANDAMENTO
		4.4 - Porta trancada - FEITO
		4.5 - Diário
		4.6 - Papéis
	5 - UI
	6 - Organizar pastas
	7 - Implementar na cena real
	8 - Ajustar mãos
	9 - Testes
	10 - Ajustes visuais
'''
