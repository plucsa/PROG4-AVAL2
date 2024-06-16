import 'package:flutter/material.dart';

import '../app/app_route.dart';
import '../models/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;

  const ItemTile(
    this.item, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime itemDate = DateTime.parse(item.date);
    final Duration difference = DateTime.now().difference(itemDate);
    final int differenceInDays = difference.inDays;

    String formatDaysDifference(int days) {
      if (days > 0) {
        return 'Venceu há $days dia(s) atrás';
      } else if (days == 0){
        return 'Vence Hoje';

      }else if (days > -3) {
        return 'Restam ${days * -1} dia(s)';
      } else {
        return '${itemDate.day}/${itemDate.month}/${itemDate.year}';
      }
    }

    final String dateDifference = formatDaysDifference(differenceInDays);
    final bool isPast = differenceInDays > 0;

    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoute.editItem.route,
          arguments: item,
        );
      },
      title: Text(item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          )),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descrição: ${item.description}'),
          Text(
            'Vencimento: $dateDifference',
            style: TextStyle(
              color: isPast ? Colors.red : differenceInDays <= -3 ? Colors.black : Color.fromARGB(255, 247, 112, 2) ,
            ),
          ),
          Text('Categoria: ${item.category}'),
        ],
      ),
    );
  }
}