import 'models.dart';

const categories = ['Entradas', 'Pizzas', 'Massas', 'Sobremesas', 'Bebidas'];

const _borda = Extra('borda', 'Borda recheada', 900);
const _queijo = Extra('queijo', 'Queijo extra', 700);
const _bacon = Extra('bacon', 'Bacon crocante', 800);
const _ovo = Extra('ovo', 'Ovo caipira', 400);
const _parm = Extra('parm', 'Parmesão ralado', 500);
const _sorvete = Extra('sorvete', 'Bola de sorvete', 800);
const _calda = Extra('calda', 'Calda extra', 400);
const _semAcucar = Extra('semacucar', 'Sem açúcar', 0);

const menu = <Dish>[
  Dish(id: 'bru', category: 'Entradas', name: 'Bruschetta de tomate', description: 'Pão de fermentação natural, tomate maduro, manjericão e azeite.', cents: 2800, tone: 0, extras: [_queijo]),
  Dish(id: 'pol', category: 'Entradas', name: 'Polenta frita', description: 'Palitos crocantes com maionese de ervas e parmesão.', cents: 3200, tone: 1, extras: [_parm, _bacon]),
  Dish(id: 'bur', category: 'Entradas', name: 'Burrata com tomates', description: 'Burrata cremosa, tomates confitados e pesto da casa.', cents: 4600, tone: 2, tag: 'Favorito'),
  Dish(id: 'mar', category: 'Pizzas', name: 'Margherita', description: 'Molho de tomate italiano, mussarela de búfala e manjericão fresco.', cents: 5200, tone: 3, extras: [_borda, _queijo], tag: 'Clássica'),
  Dish(id: 'cal', category: 'Pizzas', name: 'Calabresa artesanal', description: 'Calabresa curada, cebola roxa, azeitonas e orégano.', cents: 5600, tone: 4, extras: [_borda, _queijo, _bacon]),
  Dish(id: 'qua', category: 'Pizzas', name: 'Quatro queijos', description: 'Mussarela, gorgonzola, parmesão e catupiry original.', cents: 6200, tone: 1, extras: [_borda, _bacon]),
  Dish(id: 'por', category: 'Pizzas', name: 'Portuguesa', description: 'Presunto, ovos, cebola, ervilha e azeitonas pretas.', cents: 5800, tone: 0, extras: [_borda, _queijo, _ovo]),
  Dish(id: 'esp', category: 'Massas', name: 'Espaguete ao sugo', description: 'Massa fresca, molho de tomate rústico e manjericão.', cents: 3900, tone: 2, extras: [_parm, _queijo]),
  Dish(id: 'lad', category: 'Massas', name: 'Lasanha à bolonhesa', description: 'Camadas de massa, ragu cozido por 6 horas e bechamel.', cents: 4800, tone: 4, extras: [_parm, _queijo], tag: 'Mais pedida'),
  Dish(id: 'nho', category: 'Massas', name: 'Nhoque de batata', description: 'Nhoque macio com molho de gorgonzola e nozes.', cents: 4400, tone: 3, extras: [_parm, _bacon]),
  Dish(id: 'tir', category: 'Sobremesas', name: 'Tiramisù', description: 'Café, mascarpone e cacau, servido gelado.', cents: 2600, tone: 1, extras: [_calda]),
  Dish(id: 'pan', category: 'Sobremesas', name: 'Panna cotta', description: 'Creme de baunilha com calda de frutas vermelhas.', cents: 2400, tone: 0, extras: [_calda]),
  Dish(id: 'bro', category: 'Sobremesas', name: 'Brownie quente', description: 'Chocolate meio amargo, nozes e calda quente.', cents: 2900, tone: 4, extras: [_sorvete, _calda]),
  Dish(id: 'sup', category: 'Bebidas', name: 'Suco de laranja', description: 'Laranja espremida na hora, 400 ml.', cents: 1200, tone: 2, extras: [_semAcucar]),
  Dish(id: 'lim', category: 'Bebidas', name: 'Limonada italiana', description: 'Limão siciliano, hortelã e água com gás, 400 ml.', cents: 1400, tone: 3, extras: [_semAcucar]),
  Dish(id: 'ref', category: 'Bebidas', name: 'Refrigerante lata', description: 'Cola, guaraná ou limão, 350 ml.', cents: 600, tone: 4),
];
