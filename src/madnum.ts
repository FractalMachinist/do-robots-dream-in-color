/**
 * https://github.com/LIMPIX31/madnum/blob/master/index.ts
 * Probably because I'm running old Node, the npm package failed constantly.
 */

const units = ['', 'K', 'M', 'B', 'T']
const a = 'A'.charCodeAt(0)
const log = (n: number, b: number) => Math.log(n) / Math.log(b)
/**
 * Transform a large number into an pretty output
 * @example
 * // With dynamic precision
 * mn(1000) // 1 K
 * mn(1500000) // 1 M
 * mn(1e9) // 1 B
 * // Fixed format length
 * mn(1500, 2) // 1.50 K
 * mn(1337e3, 2) // 1.33 M
 * // Can handle infinity-like numbers
 * mn(Infinity) // ∞
 */


 const format = (number: number, options?: MadnumOptions): string => {
    if (number === 0) return '0'
    if (!isFinite(number)) return number < 0 ? '-∞' : '∞'
    const localize = (num: number) => {
      let localized = Intl.NumberFormat('en', {
        minimumFractionDigits: options?.minfd ?? 0,
        maximumFractionDigits: options?.maxfd ?? 2,
        useGrouping: !!options?.separator
      }).format(num)
      if (options?.separator)
        localized = localized.replaceAll(',', options.separator)
      return localized
    }
    if (Math.abs(number) < (options?.threshold ?? 1e3)) return localize(number)
    const negative = number < 0 ? (number = -number) : false
    const n = Math.floor(log(number, 1e3))
    const m = number / 1e3 ** n
    let unit = ''
    if (n < units.length) unit = units[n]
    else {
      const unitInt = n - units.length
      unit =
        String.fromCharCode(unitInt / 26 + a) +
        String.fromCharCode((unitInt % 26) + a)
    }
    let result = localize(negative ? -m : m)
    result = (options?.format ?? '{num}{unit}')
      .replaceAll('{num}', result)
      .replaceAll('{unit}', unit)
    if (options?.lowercase) result = result.toLowerCase()
    return result
  }


export function mn(number: number, options: MadnumOptions): string

export function mn(number: number, precision?: number): string

export function mn(
  number: number,
  precision?: number | MadnumOptions,
  threshold = 1e3
): string {
  if (typeof precision === 'number')
    return format(number, {
      maxfd: precision,
      minfd: precision,
      threshold
    })
  else return format(number, precision)
}

export interface MadnumOptions {
  /**
   * Process the number if more than threshold
   */
  threshold?: number;
  /**
   * minimum fraction digits
   */
  minfd?: number;
  /**
   * maximum fraction digits
   */
  maxfd?: number;
  /**
   * transform units to lowecase **1 K** -> **1 k**
   */
  lowercase?: boolean;
  /**
   * string format
   * default: "{num} {unit}"
   */
  format?: string;
  /**
   * thousands separator
   */
  separator?: string;
}
