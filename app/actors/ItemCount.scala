package actors

case class ItemCount(
  countsByItem: Map[String,Int] = Map(),
  itemsByCount: Map[Int,Seq[String]] = Map()
) {
  def updated(item: String, delta: Int): ItemCount = {
    val oldCount: Int = countsByItem.getOrElse(item, 0)
    val newCount: Int = oldCount + delta

    ItemCount(
      countsByItem.updated(item, newCount),
      itemsByCount.
        updated(
          oldCount,
          itemsByCount.getOrElse(oldCount, IndexedSeq()).diff(Seq(item))
        ).
        updated(
          newCount,
          itemsByCount.getOrElse(newCount, IndexedSeq()).appended(item)
        ).
        filter {
          case (count: Int, messengers: Seq[String]) =>
            count > 0 && messengers.nonEmpty
        }
    )
  }
}
