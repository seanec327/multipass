/*
 * Copyright (C) Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Alberto Aguirre <alberto.aguirre@canonical.com>
 *
 */

#include "petname.h"
#include "names_and_adjectives.h"

#include <iostream>
#include <string.h>

namespace mp = multipass;

namespace
{
constexpr auto num_names = std::extent_v<decltype(mp::petname::names)>;
constexpr auto num_adjectives = std::extent_v<decltype(mp::petname::adjectives)>;
} // namespace

mp::Petname::Petname()
    : engine{std::random_device{}()}, name_dist{0, num_names - 1}, adjective_dist{0, num_adjectives - 1}
{
}

std::string mp::Petname::make_name()
{
    return std::string{petname::adjectives[adjective_dist(engine)]} + '-' + petname::names[name_dist(engine)];
}
