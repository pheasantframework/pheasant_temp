import 'package:pheasant_temp/pheasant_temp.dart';

void main() {
  print(
    renderFunc(script: """
import './Component.phs' as Component;
import '../fruit/fruit.phs' as fruit;

var number = 9;

List<int> nums = [1, 2, 3, 4];

void addNum() {
  number++;
}

void subtractNum() {
  number -= 1;
}
""", template: """
<div class="foo" r-for="var value in nums">
  Welcome to Pheasant
  <p>Hello World</p>
  <a href="#" class="fee" id="me">Click Here</a>
  <p>Aloha</p>
  <fruit class="fred" id="foo"/>
  <p>{{value}}</p>
  <p>{{number}}</p>
</div>
""")
  );
}
