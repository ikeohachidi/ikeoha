import dayjs from 'dayjs'

export function timeFormat(time: string) {
    return dayjs(time).format('MMM DD[,] YYYY')
}