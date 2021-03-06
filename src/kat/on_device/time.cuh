/**
 * @file on_device/time.cuh
 *
 * @brief CUDA device-side functions having to do with timing and the hardware clock.
 */

#ifndef CUDA_KAT_ON_DEVICE_TIME_CUH_
#define CUDA_KAT_ON_DEVICE_TIME_CUH_


///@cond
#include <kat/define_specifiers.hpp>
///@endcond

namespace kat {

enum class sleep_resolution { clock_cycles, nanoseconds };

using clock_value_t = long long;
	// CUDA uses a signed type for clock values - for some unknown reason; See the declaration of clock64()

///@cond
namespace detail {

template <sleep_resolution Resolution>
struct sleep_unit;

template  struct sleep_unit<sleep_resolution::clock_cycles> { using type = clock_value_t; };
template  struct sleep_unit<sleep_resolution::nanoseconds > { using type = unsigned int; };
	// Why unsigned int? See the declaration of nanosleep()...

} // namespace detail
///@endcond

template <sleep_resolution Resolution>
using sleep_unit_t = typename detail::sleep_unit<Resolutiom>::type;


/**
 * @brief Have the calling warp busy-sleep for (at least) a certain
 * number of clock cycles.
 *
 * @note In 2017, a typical GPU clock cycle is around 1 ns (i.e. 1 GHz frequency).
 *
 */
template <sleep_resolution Resolution>
__fd__ void sleep(sleep_unit_t<Resolution> num_cycles);

template
__fd__ void sleep<sleep_resolution::clock_cycles>(
	sleep_unit_t<sleep_resolution::clock_cycles> num_cycles)
{
	// The clock64() function returns an SM-specific clock ticks value,
	// which occasionally gets reset. Even if it were not reset, it would
	// only wrap around in 300 years or so since it began ticking, which is
	// why there's no need to check for wrap-around.
	// Also, it seems this code is not optimized-away despite not having
	// any obvious side effects.
	clock_value_t start = clock64();
    clock_value_t cycles_elapsed;
    do { cycles_elapsed = clock64() - start; }
    while (cycles_elapsed < num_cycles);
}

#if __CUDA_ARCH__ >= 700

template
__fd__ void sleep<sleep_resolution::clock_cycles>(
	sleep_unit_t<sleep_resolution::clock_cycles> num_cycles)
{
	__nanosleep(unsigned int ns);
}

#endif // __CUDA_ARCH__ >= 700

} // namespace kat


///@cond
#include <kat/undefine_specifiers.hpp>
///@endcond

#endif // CUDA_KAT_ON_DEVICE_TIME_CUH_
